# Запуск:
#   DRY_RUN=1 bin/rails runner script/backfill_products_fk.rb   # посмотреть, что бы записалось
#   bin/rails runner script/backfill_products_fk.rb             # применить

conn = ActiveRecord::Base.connection

# ---- helpers ---------------------------------------------------------------

def col?(table, col)
  ActiveRecord::Base.connection.column_exists?(table, col)
end

def ilike_pattern(str)
  "%#{ActiveRecord::Base.sanitize_sql_like(str.to_s.strip)}%"
end

def safe_down(str)
  str.to_s.strip.downcase
end

# Поиск Model по title (если таблица/колонка есть)
def find_model_by_title(title)
  return nil unless col?(:models, :title)
  Model.find_by("LOWER(title) = ?", safe_down(title)) ||
    Model.where("title ILIKE ?", ilike_pattern(title)).order(:id).first
end

# Поиск Phone по одному из возможных полей
PHONE_TITLE_COLUMNS = %i[model_title title name].freeze
def find_phone_by_title(title)
  PHONE_TITLE_COLUMNS.each do |c|
    next unless col?(:phones, c)
    phone = Phone.find_by("LOWER(#{c}) = ?", safe_down(title))
    return phone if phone
  end
  PHONE_TITLE_COLUMNS.each do |c|
    next unless col?(:phones, c)
    phone = Phone.where("#{c} ILIKE ?", ilike_pattern(title)).order(:id).first
    return phone if phone
  end
  nil
end

# Поиск Generation: сначала по phone_id (если колонка есть), затем по своим полям
GEN_TITLE_COLUMNS = %i[title name code].freeze
def find_generation(title:, phone:)
  # a) через phone_id (если есть такая колонка)
  if phone && col?(:generations, :phone_id)
    gen = Generation.where(phone_id: phone.id).order(:id).first
    return gen if gen
  end

  # b) прямым поиском по полям generations
  GEN_TITLE_COLUMNS.each do |c|
    next unless col?(:generations, c)
    gen = Generation.find_by("LOWER(#{c}) = ?", safe_down(title))
    return gen if gen
  end
  GEN_TITLE_COLUMNS.each do |c|
    next unless col?(:generations, c)
    gen = Generation.where("#{c} ILIKE ?", ilike_pattern(title)).order(:id).first
    return gen if gen
  end

  nil
end

# ---- sanity checks ---------------------------------------------------------

unless col?(:products, :phone_id) && col?(:products, :generation_id)
  abort "❌ products.phone_id/generation_id отсутствуют. Сначала миграция AddPhoneAndGenerationToProducts и db:migrate."
end

CANDIDATE_NAME_COLUMNS = %i[name title model_name heading].freeze
PRODUCT_NAME_COLUMN = CANDIDATE_NAME_COLUMNS.find { |col| col?(:products, col) }
abort "❌ В products нет ни одного поля из: #{CANDIDATE_NAME_COLUMNS.join(', ')}" unless PRODUCT_NAME_COLUMN

puts "🔎 Использую products.#{PRODUCT_NAME_COLUMN} для матчинга."

# ---- backfill --------------------------------------------------------------

dry_run = ENV["DRY_RUN"].present?
batch   = 200
scope   = Product.where("phone_id IS NULL OR generation_id IS NULL")
total   = scope.count

puts "Backfill products needing FKs: #{total}"

updated_phone = 0
updated_gen   = 0
skipped_blank = 0
not_found     = 0
errors        = 0

scope.find_in_batches(batch_size: batch).with_index do |group, idx|
  group.each do |p|
    begin
      title = p.public_send(PRODUCT_NAME_COLUMN).to_s.strip
      if title.blank?
        skipped_blank += 1
        next
      end

      # 1) Если уже есть связи — пропускаем соответствующую часть
      phone      = p.phone
      generation = p.generation

      # 2) Пробуем найти через Model
      if phone.nil? || generation.nil?
        model = find_model_by_title(title)
        phone ||= model&.respond_to?(:phone) ? model.phone : nil
        generation ||= model&.respond_to?(:generation) ? model.generation : nil
      end

      # 3) Пробуем найти телефон, если ещё не найден
      phone ||= find_phone_by_title(title)

      # 4) Пробуем найти поколение
      generation ||= find_generation(title: title, phone: phone)

      changes = {}
      changes[:phone_id] = phone.id if phone && p.phone_id.nil?
      changes[:generation_id] = generation.id if generation && p.generation_id.nil?

      if changes.empty?
        not_found += 1
        next
      end

      if dry_run
        puts "• DRY: product##{p.id} '#{title}' -> #{changes.inspect}"
      else
        p.update_columns(changes)
        updated_phone += 1 if changes.key?(:phone_id)
        updated_gen   += 1 if changes.key?(:generation_id)
      end
    rescue => e
      errors += 1
      warn "ERR product##{p.id}: #{e.class} #{e.message}"
    end
  end
  puts "  • batch #{idx + 1}: #{group.size} processed"
end

puts "✅ Done."
puts "   updated phone_id:      #{updated_phone}"
puts "   updated generation_id: #{updated_gen}"
puts "   skipped blank title:   #{skipped_blank}"
puts "   unresolved (no match): #{not_found}"
puts "   errors:                #{errors}"
