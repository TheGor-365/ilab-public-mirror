# frozen_string_literal: true
require "yaml"
require "date"  # чтобы класс Date был загружен для safe_load

puts "==> Seeding…"

# -------------------------------
# helpers
# -------------------------------
def col?(table, col)
  ActiveRecord::Base.connection.column_exists?(table, col)
end
def has_assoc?(klass, name) = klass.reflect_on_association(name).present?

# безопасная загрузка YAML c разрешением дат/времени и алиасов
def yaml_load(path)
  YAML.safe_load(
    File.read(path),
    permitted_classes: [Date, Time],
    permitted_symbols: [],
    aliases: true
  )
end

def upsert_generation_from_row!(row, default_family: "iPhone")
  title  = row["generation_title"] || row["title"] || row["model"] || row["name"]
  raise "No generation title in row: #{row.inspect}" if title.blank?

  g = Generation.find_or_initialize_by(title: title)
  g.family          = row["family"] || default_family
  g.released_on     = row["released_on"]     if row["released_on"]
  g.discontinued_on = row["discontinued_on"] if row["discontinued_on"]
  g.aliases         = row["aliases"]         || []
  g.storage_options = row["storage_options"] || []
  g.color_options   = row["color_options"]   || []
  g.save!
  g
end

def upsert_phone_for_generation!(gen)
  return unless defined?(Phone)

  ph = Phone.find_or_initialize_by(model_title: gen.title)
  if ph.new_record?
    ph.model_overview = ""
    ph.images = []
    ph.videos = []
  end

  if ph.respond_to?(:generation_id)
    ph.generation_id = gen.id
  elsif ph.respond_to?(:generation=)
    ph.generation = gen
  end

  ph.save!(validate: false)

  if gen.respond_to?(:phone) && gen.phone.nil?
    gen.update!(phone: ph)
  elsif col?(:generations, :phone_id) && gen.respond_to?(:phone_id) && gen.phone_id.nil?
    gen.update!(phone_id: ph.id)
  end

  ph
end

def setval_sequence!(table, pk: "id")
  ActiveRecord::Base.connection.execute(<<~SQL)
    SELECT setval(pg_get_serial_sequence('#{table}','#{pk}'),
                  (SELECT COALESCE(MAX(#{pk}), 0) FROM #{table}));
  SQL
end

# -----------------------------------------------------------------------------------------
# 0) Базовые поколения 1..9 (ИДЕИ поколений)
# -----------------------------------------------------------------------------------------
%w[1 2 3 4 5 6 7 8 9].each do |t|
  Generation.find_or_create_by!(title: t) do |g|
    g.family = 'iPhone'
    g.production_period = ''
    g.features = ''
    g.vulnerability = ''
    g.images = []
    g.videos = []
  end
end

# -------------------------------
# 1) БАЗОВЫЕ 29 phone.id (совместимость)
# -------------------------------
BASE29 = [
  [ 1,  "iPhone 4"             ],
  [ 2,  "iPhone 4s"            ],
  [ 3,  "iPhone 5"             ],
  [ 4,  "iPhone 5s"            ],
  [ 5,  "iPhone 5c"            ],
  [ 6,  "iPhone SE (1st generation)"],
  [ 7,  "iPhone 6"             ],
  [ 8,  "iPhone 6 Plus"        ],
  [ 9,  "iPhone 6s"            ],
  [10,  "iPhone 6s Plus"       ],
  [11,  "iPhone 7"             ],
  [12,  "iPhone 7 Plus"        ],
  [13,  "iPhone 8"             ],
  [14,  "iPhone 8 Plus"        ],
  [15,  "iPhone X"             ],
  [16,  "iPhone XS"            ],
  [17,  "iPhone XS Max"        ],
  [18,  "iPhone XR"            ],
  [19,  "iPhone 11"            ],
  [20,  "iPhone 11 Pro"        ],
  [21,  "iPhone 11 Pro Max"    ],
  [22,  "iPhone 12 mini"       ],
  [23,  "iPhone 12"            ],
  [24,  "iPhone 12 Pro"        ],
  [25,  "iPhone 12 Pro Max"    ],
  [26,  "iPhone 13"            ],
  [27,  "iPhone 13 mini"       ],
  [28,  "iPhone 13 Pro"        ],
  [29,  "iPhone 13 Pro Max"    ]
]

ActiveRecord::Base.transaction do
  BASE29.each do |(fixed_id, title)|
    gen = Generation.find_or_create_by!(title: title) { |g| g.family = "iPhone" }

    ph = Phone.find_by(id: fixed_id)
    if ph
      changes = {}
      changes[:model_title] = title if ph.model_title != title
      if ph.respond_to?(:generation_id) && ph.generation_id != gen.id
        changes[:generation_id] = gen.id
      end
      ph.update!(changes) if changes.any?
    else
      attrs = {
        id: fixed_id,
        model_title: title,
        model_overview: "",
        images: [],
        videos: []
      }
      attrs[:generation_id] = gen.id if Phone.column_names.include?("generation_id")
      ph = Phone.new(attrs)
      ph.save!(validate: false)
    end

    if gen.respond_to?(:phone) && gen.phone.nil?
      gen.update!(phone: ph)
    elsif col?(:generations, :phone_id) && gen.respond_to?(:phone_id) && gen.phone_id.nil?
      gen.update!(phone_id: ph.id)
    end
  end

  setval_sequence!("phones")
end
puts "→ Ensured base 29 phones (IDs 1..29)."

# -------------------------------
# 2) Полный импорт iPhone из YAML
# -------------------------------
iphones_yml = Rails.root.join("db", "catalog", "apple", "iphones.yml")
if File.exist?(iphones_yml)
  rows = yaml_load(iphones_yml)
  count = 0
  rows.each do |row|
    gen = upsert_generation_from_row!(row, default_family: "iPhone")
    upsert_phone_for_generation!(gen)
    count += 1
  end
  puts "→ Imported iPhone generations from YAML: #{count} rows."
else
  puts "→ SKIP iphones.yml (file not found: #{iphones_yml})"
end

# какие классы считаем девайсами внутри каждого семейства
FAMILY_DEVICE_CLASSES = {
  "iPhone"      => %w[Phone],
  "iPad"        => %w[Ipad],
  "Mac"         => %w[Imac MacMini MacPro MacStudio Macbook MacbookAir MacbookPro],
  "Apple Watch" => %w[AppleWatch],
  "AirPods"     => %w[Airpod],
  "Apple TV"    => %w[AppleTv],
  "HomePod"     => %w[Homepod],
  "Accessories" => %w[Accessory]
}.freeze

# --- канонические категории по семействам (ФИКС: раньше константа отсутствовала) ---
CATEGORIES_BY_FAMILY = {
  "iPhone"      => %w[Ремонт Неисправности Модификации Запчасти Аксессуары Сервис],
  "iPad"        => %w[Ремонт Неисправности Модификации Запчасти Аксессуары Сервис],
  "Mac"         => %w[Ремонт Неисправности Модификации Запчасти Аксессуары Сервис],
  "Apple Watch" => %w[Ремонт Неисправности Запчасти Аксессуары Сервис],
  "AirPods"     => %w[Ремонт Запчасти Аксессуары Сервис],
  "Apple TV"    => %w[Аксессуары Сервис],
  "HomePod"     => %w[Ремонт Аксессуары Сервис],
  "Accessories" => %w[Каталог]
}.freeze unless defined?(CATEGORIES_BY_FAMILY)

def create_category_for!(device, heading)
  if Category.column_names.include?("device_type") && Category.column_names.include?("device_id")
    Category.find_or_create_by!(device: device, heading: heading) do |c|
      c.display  = true
      c.overview = ""
      c.avatar   = ""
      c.images   = []
      c.videos   = []
    end
  else
    return unless device.is_a?(Phone)
    Category.find_or_create_by!(phone_id: device.id, heading: heading) do |c|
      c.display  = true
      c.overview = ""
      c.avatar   = ""
      c.images   = []
      c.videos   = []
    end
  end
end

def constant_defined?(name)
  Object.const_defined?(name) && Object.const_get(name).respond_to?(:all)
rescue NameError
  false
end

created_total = 0
CATEGORIES_BY_FAMILY.each do |family, headings|
  Generation.where(family: family).find_each do |gen|
    headings.each do |h|
      Category.find_or_create_by!(device: gen, heading: h) do |c|
        c.display  = true
        c.overview = ""
        c.avatar   = ""
        c.images   = []
        c.videos   = []
      end
      created_total += 1
    end
  end
end

puts "→ Canonical categories applied (created/ensured ~#{created_total})."

# -----------------------------------------------------------------------------------------
# users
# -----------------------------------------------------------------------------------------
User.create([
  { username: 'sarah',    admin: true,  author: true,  repairman: true,  teacher: true,  student: true,  customer: true, email: 'sarah@example.com',    password: 'Password1' },
  { username: 'emily',    admin: false, author: false, repairman: false, teacher: false, student: true,  customer: true, email: 'emily@example.com',    password: 'Password1' },
  { username: 'melanie',  admin: false, author: true,  repairman: false, teacher: false, student: true,  customer: true, email: 'melanie@example.com',  password: 'Password1' },
  { username: 'caroline', admin: false, author: true,  repairman: true,  teacher: false, student: false, customer: true, email: 'caroline@example.com', password: 'Password1' },
  { username: 'bridget',  admin: false, author: true,  repairman: false, teacher: true,  student: false, customer: true, email: 'bridget@example.com',  password: 'Password1' },
  { username: 'jane',     admin: false, author: false, repairman: false, teacher: false, student: false, customer: true, email: 'jane@example.com',  password: 'Password1' }
])

# -----------------------------------------------------------------------------------------
# IPHONE MODELS
# -----------------------------------------------------------------------------------------
Model.create([
  { generation_id: 1, phone_id: 1,  title: 'iphone 4',          images: [], videos: [] },
  { generation_id: 1, phone_id: 2,  title: 'iphone 4s',         images: [], videos: [] },
  { generation_id: 2, phone_id: 3,  title: 'iphone 5',          images: [], videos: [] },
  { generation_id: 2, phone_id: 4,  title: 'iphone 5s',         images: [], videos: [] },
  { generation_id: 2, phone_id: 5,  title: 'iphone 5c',         images: [], videos: [] },
  { generation_id: 2, phone_id: 6,  title: 'iphone SE',         images: [], videos: [] },
  { generation_id: 3, phone_id: 7,  title: 'iphone 6',          images: [], videos: [] },
  { generation_id: 3, phone_id: 8,  title: 'iphone 6 plus',     images: [], videos: [] },
  { generation_id: 3, phone_id: 9,  title: 'iphone 6s',         images: [], videos: [] },
  { generation_id: 3, phone_id: 10, title: 'iphone 6s plus',    images: [], videos: [] },
  { generation_id: 4, phone_id: 11, title: 'iphone 7',          images: [], videos: [] },
  { generation_id: 4, phone_id: 12, title: 'iphone 7 plus',     images: [], videos: [] },
  { generation_id: 5, phone_id: 13, title: 'iphone 8',          images: [], videos: [] },
  { generation_id: 5, phone_id: 14, title: 'iphone 8 plus',     images: [], videos: [] },
  { generation_id: 6, phone_id: 15, title: 'iphone X',          images: [], videos: [] },
  { generation_id: 6, phone_id: 16, title: 'iphone XS',         images: [], videos: [] },
  { generation_id: 6, phone_id: 17, title: 'iphone XS Max',     images: [], videos: [] },
  { generation_id: 6, phone_id: 18, title: 'iphone XR',         images: [], videos: [] },
  { generation_id: 7, phone_id: 19, title: 'iphone 11',         images: [], videos: [] },
  { generation_id: 7, phone_id: 20, title: 'iphone 11 Pro',     images: [], videos: [] },
  { generation_id: 7, phone_id: 21, title: 'iphone 11 Pro Max', images: [], videos: [] },
  { generation_id: 8, phone_id: 22, title: 'iphone 12 Mini',    images: [], videos: [] },
  { generation_id: 8, phone_id: 23, title: 'iphone 12',         images: [], videos: [] },
  { generation_id: 8, phone_id: 24, title: 'iphone 12 Pro',     images: [], videos: [] },
  { generation_id: 8, phone_id: 25, title: 'iphone 12 Pro Max', images: [], videos: [] },
  { generation_id: 9, phone_id: 26, title: 'iphone 13',         images: [], videos: [] },
  { generation_id: 9, phone_id: 27, title: 'iphone 13 Mini',    images: [], videos: [] },
  { generation_id: 9, phone_id: 28, title: 'iphone 13 Pro',     images: [], videos: [] },
  { generation_id: 9, phone_id: 29, title: 'iphone 13 Pro Max', images: [], videos: [] },
])

def seed_demo_products!(per_generation: 10)
  seller = User.find_by(email: 'sarah@example.com') || User.first

  Generation.find_each do |gen|
    storages = Array(gen.storage_options.presence || ["64GB"])
    colors   = Array(gen.color_options.presence   || ["Black"])
    combos   = storages.product(colors).first(per_generation)

    combos.each_with_index do |(st, col), idx|
      Product.find_or_create_by!(generation: gen, storage: st, color: col) do |p|
        p.name       = [gen.title, st, col].compact.join(" ")
        p.price      = 199 + idx * 10
        p.currency   = "$"
        p.state      = :active
        p.condition  = :used
        p.seller     = seller
        p.images     = []
        p.videos     = []
      end
    end
  end
end

seed_demo_products!
puts "→ Seeded demo products (up to 10 per generation)."

University.create([
  { title: 'iLab', avatar: '', images: [], videos: [] }
])

# === Bulk-загрузка Rem/Def/Mod/SparePart ===
require_relative 'seeds/support/bulk'
require_relative 'seeds/support/validate'
require_relative 'seeds/support/join_models'
include SeedBulk
include SeedValidate

# Подключаем массивы данных, если файлы существуют
require_relative 'seeds/data/repairs_data'     if File.exist?(Rails.root.join('db/seeds/data/repairs_data.rb'))
require_relative 'seeds/data/defects_data'     if File.exist?(Rails.root.join('db/seeds/data/defects_data.rb'))
require_relative 'seeds/data/mods_data'        if File.exist?(Rails.root.join('db/seeds/data/mods_data.rb'))
require_relative 'seeds/data/spare_parts_data' if File.exist?(Rails.root.join('db/seeds/data/spare_parts_data.rb'))

# --- словарь синонимов для привязки по имени модуля ---
NAME_SYNONYMS = {
  'display'               => %w[display screen assembly lcd screen lcd display screen assembly],
  'logic board'           => %w[logic board mainboard motherboard],
  'battery'               => %w[battery accumulator],
  'lower loop'            => %w[lower loop charging-assembly dock flex charging port],
  'higher loop'           => %w[higher loop top flex sensor flex],
  'rear camera'           => %w[rear camera main camera],
  'front-facing camera'   => %w[front-facing camera selfie camera front camera],
  'home button'           => %w[home button touch id home key]
}.freeze

def expand_names(names)
  base = Array(names).map { |n| n.to_s.strip }.reject(&:blank?)
  base.flat_map { |n| NAME_SYNONYMS[n.downcase] || [n] }
      .map(&:downcase)
      .uniq
end

ActiveRecord::Base.logger.silence do
  # ---- MODS ----
  if defined?(MODS_DATA)
    puts "[seeds] MODS_DATA validate..."
    SeedValidate.warn_unknown_keys("Mod", MODS_DATA)
    puts "[seeds] MODS_DATA insert..."
    SeedBulk.chunked_insert(Mod, MODS_DATA)
  end

  # ---- DEFECTS ----
  if defined?(DEFECTS_DATA)
    puts "[seeds] DEFECTS_DATA validate..."
    SeedValidate.warn_unknown_keys("Defect", DEFECTS_DATA)
    puts "[seeds] DEFECTS_DATA insert..."
    SeedBulk.chunked_insert(Defect, DEFECTS_DATA)

    # defects <-> phones — БЕЗ timestamps
    if ActiveRecord::Base.connection.table_exists?('defects_phones')
      rows = Defect.where.not(phone_id: nil)
                   .pluck(:id, :phone_id)
                   .map { |did, pid| { defect_id: did, phone_id: pid } }
      rows.uniq! { |r| [r[:defect_id], r[:phone_id]] }
      DefectsPhone.insert_all(rows) if rows.any?
    end

    # defects <-> mods по названию в :modules (с синонимами) — БЕЗ timestamps
    if ActiveRecord::Base.connection.table_exists?('defects_mods')
      Defect.find_in_batches(batch_size: 1000) do |batch|
        rows = []
        batch.each do |d|
          next if d.modules.blank?
          normalized = expand_names(d.modules)
          next if normalized.empty?
          mods = Mod.where("LOWER(name) IN (?)", normalized)
          mods.pluck(:id).each { |mid| rows << { defect_id: d.id, mod_id: mid } }
        end
        rows.uniq! { |r| [r[:defect_id], r[:mod_id]] }
        DefectsMod.insert_all(rows) if rows.any?
      end
    end
  end

  # ---- REPAIRS ----
  if defined?(REPAIRS_DATA)
    puts "[seeds] REPAIRS_DATA validate..."
    SeedValidate.warn_unknown_keys("Repair", REPAIRS_DATA)
    puts "[seeds] REPAIRS_DATA insert..."
    SeedBulk.chunked_insert(Repair, REPAIRS_DATA)

    # repairs <-> phones — БЕЗ timestamps
    if ActiveRecord::Base.connection.table_exists?('phones_repairs')
      rows = Repair.where.not(phone_id: nil)
                   .pluck(:id, :phone_id)
                   .map { |rid, pid| { repair_id: rid, phone_id: pid } }
      rows.uniq! { |r| [r[:repair_id], r[:phone_id]] }
      PhonesRepair.insert_all(rows) if rows.any?
    end

    # repairs <-> mods по названию в :spare_parts (с синонимами) — БЕЗ timestamps
    if ActiveRecord::Base.connection.table_exists?('mods_repairs')
      Repair.find_in_batches(batch_size: 1000) do |batch|
        rows = []
        batch.each do |r|
          next if r.spare_parts.blank?
          normalized = expand_names(r.spare_parts)
          next if normalized.empty?
          mods = Mod.where("LOWER(name) IN (?)", normalized)
          mods.pluck(:id).each { |mid| rows << { repair_id: r.id, mod_id: mid } }
        end
        rows.uniq! { |r| [r[:repair_id], r[:mod_id]] }
        ModsRepair.insert_all(rows) if rows.any?
      end
    end

    # repairs <-> defects по полю defect_id (ФИКС: вставляем только существующие связки)
    if ActiveRecord::Base.connection.table_exists?('defects_repairs')
      repairs = Repair.where.not(defect_id: nil)
      existing_defect_ids = Defect.where(id: repairs.select(:defect_id)).pluck(:id)
      if existing_defect_ids.any?
        rows = repairs.where(defect_id: existing_defect_ids)
                      .pluck(:id, :defect_id)
                      .map { |rid, did| { repair_id: rid, defect_id: did } }
        rows.uniq! { |r| [r[:repair_id], r[:defect_id]] }
        DefectsRepair.insert_all(rows) if rows.any?
      end

      # На всякий: "обнулим" битые внешние ключи в repairs.defect_id,
      # если вдруг такие попали из данных.
      orphan_defect_ids = repairs.pluck(:defect_id).uniq - existing_defect_ids
      if orphan_defect_ids.any?
        Repair.where(defect_id: orphan_defect_ids).update_all(defect_id: nil)
      end
    end
  end

  # ---- SPARE PARTS ----
  if defined?(SPARE_PARTS_DATA)
    puts "[seeds] SPARE_PARTS_DATA validate..."
    SeedValidate.warn_unknown_keys("SparePart", SPARE_PARTS_DATA)
    puts "[seeds] SPARE_PARTS_DATA insert..."
    SeedBulk.chunked_insert(SparePart, SPARE_PARTS_DATA)
  end
end

puts "[seeds] bulk part done."

# Универсальный импорт из всех *.yml каталогов (кроме iphones.yml)
Dir[Rails.root.join("db","catalog","apple","*.yml")].sort.each do |path|
  next if File.basename(path) == "iphones.yml"
  rows = yaml_load(path)
  imported = 0
  rows.each do |row|
    family = row["family"] || "Accessories"
    gen = upsert_generation_from_row!(row, default_family: family)
    upsert_phone_for_generation!(gen) if family == "iPhone"
    imported += 1
  end
  puts "→ Imported from #{File.basename(path)}: #{imported} rows."
end
