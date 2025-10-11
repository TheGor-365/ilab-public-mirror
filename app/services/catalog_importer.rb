# frozen_string_literal: true

require 'yaml'
require 'date'

class CatalogImporter
  PERMITTED_YAML_CLASSES = [Date, Time].freeze

  def initialize(logger: Rails.logger)
    @logger = logger || Logger.new($stdout)
    @stats  = { rows: 0, ok: 0, fail: 0 }
  end

  def import!(family:, path:)
    entries = safe_load_yaml(path)
    unless entries.is_a?(Array)
      raise ArgumentError, "YAML must be an Array of rows, got: #{entries.class}"
    end

    family_down = family.to_s.downcase
    model_cols  = Model.column_names

    entries.each do |raw_row|
      @stats[:rows] += 1
      row = (raw_row.is_a?(Hash) ? raw_row : {}).transform_keys(&:to_s)
      next unless row["family"].to_s.downcase == family_down

      begin
        ActiveRecord::Base.transaction do
          gen_title = row.fetch("generation_title")

          generation = Generation.find_or_initialize_by(title: gen_title)
          set_if_column(generation, :family,          row["family"])
          set_if_column(generation, :aliases,         Array(row["aliases"]).map(&:to_s).uniq)
          set_if_column(generation, :released_on,     safe_date(row["released_on"]))
          set_if_column(generation, :discontinued_on, safe_date(row["discontinued_on"]))
          set_if_column(generation, :storage_options, Array(row["storage_options"]).map(&:to_s).uniq)
          set_if_column(generation, :color_options,   Array(row["color_options"]).map(&:to_s).uniq)
          generation.save!  # гарантируем ID

          # ✅ Создаём Phone без зависимости от has_many :phones у Generation
          phone_title = (row["phone_model_title"].presence || gen_title).to_s
          phone = Phone.find_or_create_by!(generation: generation, model_title: phone_title)

          # Базовая модель поколения
          base_model_attrs = model_key_hash(model_cols, generation, phone, gen_title)
          Model.find_or_create_by!(base_model_attrs)

          # Варианты модели (если есть)
          Array(row["model_variants"]).each do |mv|
            mv = mv.is_a?(Hash) ? mv.transform_keys(&:to_s) : { "title" => mv.to_s }
            title = mv["title"].to_s
            next if title.blank?
            attrs = model_key_hash(model_cols, generation, phone, title)
            Model.find_or_create_by!(attrs)
          end

          attach_defaults!(generation, row["defaults"] || {}) # заглушка
        end

        @stats[:ok] += 1
        @logger.info "✓ Imported: #{family} → #{row['generation_title']}"
      rescue => e
        @stats[:fail] += 1
        @logger.error "✗ Import failed for #{row['generation_title'] || 'N/A'}: #{e.class} - #{e.message}"
        @logger.error e.backtrace.first(3).join("\n")
        raise if ENV['ILAB_IMPORT_STRICT'] == '1'
      end
    end

    @logger.info "== Import summary: rows=#{@stats[:rows]}, ok=#{@stats[:ok]}, fail=#{@stats[:fail]} =="
  end

  private

  def safe_load_yaml(path)
    raw = File.read(path)
    Psych.safe_load(
      raw,
      permitted_classes: PERMITTED_YAML_CLASSES,
      permitted_symbols: [],
      aliases: true
    )
  end

  def safe_date(val)
    return nil if val.blank?
    return val if val.is_a?(Date)
    Date.parse(val.to_s)
  rescue ArgumentError
    nil
  end

  def model_key_hash(model_cols, generation, phone, title)
    attrs = { title: title.to_s }
    attrs[:generation_id] = generation.id if model_cols.include?('generation_id')
    attrs[:phone_id]      = phone.id      if model_cols.include?('phone_id')
    attrs
  end

  def set_if_column(record, attr, value)
    record.send("#{attr}=", value) if record.has_attribute?(attr)
  end

  def attach_defaults!(_generation, _defaults)
    # Подключим, когда появятся блоки defaults в YAML.
  end
end
