# frozen_string_literal: true
#
# Usage:
#   bin/rails "ilab:catalog:import_all"
#     → Импортирует все YAML из db/catalog/apple/*.yml (где возможно подсказывает family).
#
#   bin/rails "ilab:catalog:ensure_min_products[10,all]"
#   # В Zsh ОБЯЗАТЕЛЬНО в кавычках ↑
#     → Гарантирует минимум N активных товаров на КАЖДОЕ семейство
#       (перед созданием лечит «битые» товары: цена/сток/статус/поля).
#
#   # Альтернатива без скобок (удобно для Zsh):
#   PER=10 SCOPE=all bin/rails ilab:catalog:ensure_min_products_env
#
#   bin/rails ilab:catalog:bootstrap_demo_families
#     → Создаёт минимальные демо-поколения, если каталога нет.
#
#   bin/rails ilab:catalog:families
#     → Список семейств и количество поколений.
#
#   bin/rails "ilab:catalog:coverage[iphones]"
#     → Сверка iphones.yml ↔ БД.
#
#   bin/rails ilab:catalog:fixup_invalid_products
#     → Починить существующие товары с price<=0/пустыми полями (без создания новых).

require "yaml"
require "date"

PERMITTED_YAML_CLASSES = [Date, Time].freeze

namespace :ilab do
  namespace :catalog do
    # ---------- helpers ----------
    def _state_active_value
      if Product.respond_to?(:states) && (Product.states.key?("active") || Product.states.key?(:active))
        Product.states["active"] || Product.states[:active]
      else
        col = Product.columns_hash["state"]
        col&.type == :integer ? 0 : "active"
      end
    end

    def _condition_default_value
      if Product.respond_to?(:conditions) && (Product.conditions.key?("used_good") || Product.conditions.key?(:used_good))
        Product.conditions["used_good"] || Product.conditions[:used_good]
      else
        col = Product.columns_hash["condition"]
        col&.type == :integer ? 1 : "used_good"
      end
    end

    def _presence_required?(klass, assoc_name)
      return false unless defined?(klass) && klass.respond_to?(:reflect_on_association)
      assoc = klass.reflect_on_association(assoc_name)
      required_by_assoc = assoc && (assoc.options.key?(:optional) ? !assoc.options[:optional] : true)
      required_by_validator =
        klass.respond_to?(:validators_on) &&
        klass.validators_on(assoc_name).any? { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
      required_by_assoc || required_by_validator
    end

    def _ensure_phone_for(g)
      return nil unless Object.const_defined?("Phone")
      Phone.find_or_create_by!(generation: g, model_title: g.title)
    end

    def _ensure_model_for(g, phone: nil)
      raise "Model class is missing" unless Object.const_defined?("Model")

      needs_phone = _presence_required?(Model, :phone)
      pval = phone
      pval ||= _ensure_phone_for(g) if needs_phone

      attrs = { generation: g, title: g.title }
      attrs[:phone] = pval if Model.reflect_on_association(:phone) && pval

      Model.find_or_create_by!(attrs)
    end

    def _storages_for(g)
      Array(g.storage_options).presence || %w[64GB 128GB 256GB]
    end

    def _colors_for(g)
      Array(g.color_options).presence || %w[Black Silver Blue]
    end

    def _compute_price(family:, storage:)
      base = (family == "iPhone" ? 300 : 250)
      mult = storage.to_s[/\d+/].to_i
      mult = 64 if mult.zero?
      (base * [mult / 64.0, 1.0].max).round(-1)
    end

    def _ensure_pricing!(p, family:, storage:)
      if p.has_attribute?(:price)
        price = _compute_price(family: family, storage: storage)
        p.price = price if p.price.nil? || p.price.to_f <= 0
        if p.has_attribute?(:price_cents) && (p.price_cents.nil? || p.price_cents.to_i <= 0)
          p.price_cents = (price * 100).to_i
        end
      elsif p.has_attribute?(:price_cents)
        cents = _compute_price(family: family, storage: storage) * 100
        p.price_cents = cents if p.price_cents.nil? || p.price_cents.to_i <= 0
      end
    end

    def _ensure_common_defaults!(p, family:, storage:, color:, generation_title:)
      _ensure_pricing!(p, family: family, storage: storage)
      p.name        ||= [generation_title, storage, color].compact.join(" ")
      p.description ||= "Refurbished #{generation_title} • #{storage} • #{color}"
      p.currency    ||= "USD" if p.has_attribute?(:currency)
      if p.has_attribute?(:state)
        active = _state_active_value
        p.state = active if p.state.nil? || p.state != active
      end
      if p.has_attribute?(:condition)
        cond_default = _condition_default_value
        p.condition = cond_default if p.condition.nil?
      end
      if p.has_attribute?(:stock)
        p.stock = 1 if p.stock.nil? || p.stock.to_i <= 0
      end
      p
    end

    # ---------- import all ----------
    desc "Импортирует все YAML из db/catalog/apple/*.yml (если доступны)"
    task :import_all => :environment do
      importer = defined?(CatalogImporter) ? CatalogImporter.new(logger: Logger.new($stdout)) : nil
      dir = Rails.root.join("db/catalog/apple")
      unless Dir.exist?(dir)
        puts "No dir: #{dir} — skipping import"
        next
      end

      file_family = {
        "airpods.yml"           => "AirPods",
        "airports_network.yml"  => "Networking",
        "apple_tv.yml"          => "Apple TV",
        "displays.yml"          => "Display",
        "homepod.yml"           => "HomePod",
        "input_audio_misc.yml"  => "Accessories",
        "ipads.yml"             => "iPad",
        "iphones.yml"           => "iPhone",
        "ipods.yml"             => "iPod",
        "mac_desktops.yml"      => "Mac",
        "mac_portables.yml"     => "MacBook",
        "newton_pippin.yml"     => "Newton",
        "printers_scanners.yml" => "Accessories",
        "vision.yml"            => "Vision Pro",
        "watches.yml"           => "Apple Watch",
      }

      yamls = Dir[dir.join("*.yml")].sort
      if yamls.empty?
        puts "No YAML files in #{dir} — skipping import"
        next
      end

      yamls.each do |path|
        if importer
          fname  = File.basename(path)
          family = file_family[fname]
          puts "Importing: #{path}"
          begin
            if family
              importer.import!(family: family, path: path)
            else
              importer.import!(path: path)
            end
          rescue => e
            warn "Import failed for #{fname} (#{e.class}: #{e.message})"
          end
        else
          puts "CatalogImporter is not defined — skipping #{path}"
        end
      end

      fams = Generation.distinct.order(:family).pluck(:family)
      puts "Families in DB after import: #{fams.join(', ')}"
    end

    # ---------- demo bootstrap ----------
    desc "Создаёт минимальные демо-поколения для основных семейств (если каталога нет)"
    task :bootstrap_demo_families => :environment do
      seeds = {
        "iPhone"      => %w[iPhone\ 11 iPhone\ 12 iPhone\ 13],
        "iPad"        => %w[iPad\ 9 iPad\ 10 iPad\ Air\ 4],
        "MacBook"     => %w[MacBook\ Air\ 2019 MacBook\ Pro\ 13\ 2020 MacBook\ Pro\ 14\ 2021],
        "Mac"         => %w[Mac\ mini\ 2018 Mac\ Studio\ 2022 Mac\ Pro\ 2019],
        "iMac"        => %w[iMac\ 21.5\ 2017 iMac\ 27\ 2019 iMac\ 24\ 2021],
        "Apple Watch" => %w[Watch\ S5 Watch\ S6 Watch\ S7],
        "AirPods"     => %w[AirPods\ 2 AirPods\ 3 AirPods\ Pro],
        "HomePod"     => %w[HomePod HomePod\ mini HomePod\ 2],
        "Apple TV"    => %w[Apple\ TV\ HD Apple\ TV\ 4K],
        "Display"     => %w[Studio\ Display Pro\ Display\ XDR],
        "iPod"        => %w[iPod\ touch\ 6 iPod\ touch\ 7],
        "Vision Pro"  => %w[Vision\ Pro],
        "Accessories" => %w[Magic\ Keyboard Magic\ Mouse Smart\ Keyboard\ Folio],
        "Networking"  => %w[AirPort\ Express AirPort\ Extreme Time\ Capsule],
        "Newton"      => %w[MessagePad\ 120 MessagePad\ 2000],
        "Pippin"      => %w[Atmark],
      }

      created = 0
      seeds.each do |family, titles|
        titles.each do |title|
          g = Generation.find_or_initialize_by(title: title)
          next if g.persisted?
          g.family           = family
          g.aliases          = []
          g.storage_options  = %w[64GB 128GB 256GB]
          g.color_options    = %w[Black Silver Blue]
          g.released_on      = Date.new(2020, 1, 1)
          g.discontinued_on  = nil
          g.save!
          created += 1
        end
      end
      puts "Demo generations bootstrapped: +#{created}"
    end

    # ---------- fixup invalid products (standalone) ----------
    desc "Починить существующие товары с нулевой ценой/пустыми полями (без создания новых)"
    task :fixup_invalid_products => :environment do
      active = _state_active_value
      fixed = 0

      Generation.distinct.pluck(:family).compact.each do |family|
        gens = Generation.where(family: family)
        next if gens.empty?

        scope = Product.where(generation_id: gens.select(:id))
                       .where("COALESCE(price,0) <= 0 OR storage IS NULL OR storage = '' OR color IS NULL OR color = '' OR stock IS NULL OR stock <= 0 OR state IS NULL OR state != ?", active)

        scope.find_each do |p|
          g = gens.find { |x| x.id == p.generation_id } || Generation.find_by(id: p.generation_id)
          next unless g
          storage = p.storage.presence || _storages_for(g).sample
          color   = p.color.presence   || _colors_for(g).sample
          _ensure_common_defaults!(p, family: family, storage: storage, color: color, generation_title: g.title)
          p.save!
          fixed += 1
        end
      end

      puts "✓ fixup_invalid_products done, fixed: #{fixed}"
    end

    # ---------- ensure min products per family ----------
    desc "Гарантирует минимум N активных товаров на семейство (по разным поколениям/цветам/стораджам)"
    task :ensure_min_products, [:per_family, :scope] => :environment do |_, args|
      per_family = (args[:per_family] || 10).to_i
      scope      = (args[:scope].presence || "all").to_s

      fams =
        case scope
        when "iphones" then ["iPhone"]
        else Generation.distinct.order(:family).pluck(:family).map(&:to_s).reject(&:blank?)
        end
      raise "No families found. Run ilab:catalog:import_all or ilab:catalog:bootstrap_demo_families" if fams.empty?

      state_active   = _state_active_value
      product_needs_phone = _presence_required?(Product, :phone)

      created_total  = 0
      fixed_total    = 0

      fams.each do |family|
        gens = Generation.where(family: family).order(:id)
        if gens.empty?
          puts "Family '#{family}' has no generations — skipping"
          next
        end

        # 0) Сначала чиним существующие «битые» товары семейства (цена/сток/статус/поля)
        scope_fix = Product.where(generation_id: gens.select(:id))
                           .where("COALESCE(price,0) <= 0 OR storage IS NULL OR storage = '' OR color IS NULL OR color = '' OR stock IS NULL OR stock <= 0 OR state IS NULL OR state != ?", state_active)
        scope_fix.find_each do |p|
          g = gens.find { |x| x.id == p.generation_id } || Generation.find_by(id: p.generation_id)
          next unless g
          storage = p.storage.presence || _storages_for(g).sample
          color   = p.color.presence   || _colors_for(g).sample
          _ensure_common_defaults!(p, family: family, storage: storage, color: color, generation_title: g.title)
          p.save!
          fixed_total += 1
        end

        # 1) Пересчитываем активные после фикса
        existing = Product.joins("LEFT JOIN generations g ON g.id = products.generation_id")
                          .where("g.family = ?", family)
                          .where(products: { state: state_active })
                          .count

        need = [per_family - existing, 0].max
        puts "Family=#{family}: existing active=#{existing}, need to add=#{need}"
        next if need.zero?

        gens.cycle.take(need).each do |g|
          # Готовим phone/model при необходимости валидациями
          phone = nil
          if _presence_required?(Model, :phone) || product_needs_phone
            phone = _ensure_phone_for(g)
          end
          model = _ensure_model_for(g, phone: phone)

          storage = _storages_for(g).sample
          color   = _colors_for(g).sample

          attrs = {
            generation_id: g.id,
            model_id:      model.id,
            storage:       storage,
            color:         color
          }
          attrs[:phone_id] = (phone || model.try(:phone))&.id if product_needs_phone || Product.reflect_on_association(:phone)

          p = Product.find_or_initialize_by(attrs)

          # Если вдруг уже есть, но он «битый» — лечим вместо генерации нового
          if p.persisted?
            _ensure_common_defaults!(p, family: family, storage: storage, color: color, generation_title: g.title)
            p.save! if p.changed?
            next
          end

          _ensure_common_defaults!(p, family: family, storage: storage, color: color, generation_title: g.title)

          begin
            p.save!
            created_total += 1
          rescue => e
            warn "Product create failed for #{family}/#{g.title}: #{e.class}: #{e.message}"
          end
        end
      end

      puts "✓ ensure_min_products done, created: #{created_total}, fixed: #{fixed_total}"
    end

    # Удобная обёртка без скобок (Zsh-friendly): PER=10 SCOPE=all bin/rails ilab:catalog:ensure_min_products_env
    desc "ENV-вариант ensure_min_products (PER=10 SCOPE=all)"
    task :ensure_min_products_env => :environment do
      per   = ENV.fetch("PER", "10").to_i
      scope = ENV.fetch("SCOPE", "all")
      Rake::Task["ilab:catalog:ensure_min_products"].invoke(per, scope)
    end

    # ---------- service info ----------
    desc "Покрытие каталога: YAML iphones vs DB (наследие)"
    task :coverage, [:scope] => :environment do |_, args|
      scope = (args[:scope].presence || "iphones").to_s
      case scope
      when "iphones"
        path = Rails.root.join("db/catalog/apple/iphones.yml")
        unless File.exist?(path)
          puts "YAML not found: #{path} (skip)"
          next
        end

        raw = File.read(path)
        yaml = Psych.safe_load(raw, permitted_classes: PERMITTED_YAML_CLASSES, permitted_symbols: [], aliases: true)
        rows = Array(yaml).map { |row| row.transform_keys(&:to_s) }
        in_yaml = rows.select { |x| x["family"].to_s == "iPhone" }
                      .map { |x| x["generation_title"].to_s }.reject(&:blank?).uniq.sort
        in_db = Generation.where(family: "iPhone").pluck(:title).map(&:to_s).uniq.sort

        missing = in_yaml - in_db
        extra   = in_db - in_yaml

        puts "YAML iPhones: #{in_yaml.size}"
        puts "DB   iPhones: #{in_db.size}"
        puts "Missing in DB: #{missing.size}"
        missing.first(50).each { |t| puts "  - #{t}" }
        puts "Extra in DB: #{extra.size}"
        extra.first(50).each { |t| puts "  - #{t}" }
      else
        puts "Add more scopes later."
      end
    end

    desc "Список семейств и число поколений"
    task :families => :environment do
      rows = Generation.group(:family).order(:family).count
      if rows.blank?
        puts "No generations found."
      else
        rows.each { |fam, cnt| puts "#{fam.ljust(14)}  #{cnt} generations" }
      end
    end

    desc "Бэкфилл products по name → связи (аккуратно)"
    task :backfill_products_by_name => :environment do
      updated = 0
      Product.where(generation_id: nil).find_each do |p|
        ctx = p.respond_to?(:resolve_relations_by_name) ? p.resolve_relations_by_name : {}
        next unless ctx[:generation]

        p.update_columns(
          generation_id: ctx[:generation].id,
          phone_id: ctx[:phone]&.id
        )
        updated += 1
      end
      puts "✓ backfilled products: #{updated}"
    end
  end
end
