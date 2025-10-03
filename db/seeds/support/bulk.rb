# db/seeds/support/bulk.rb
module SeedBulk
  module_function

  # Унифицированная пакетная вставка:
  # - выравнивает ключи по колонкам модели (одинаковый набор ключей для всех рядов)
  # - автоматически проставляет created_at/updated_at, если такие колонки есть
  # - для array-колонок подставляет [] когда значение не задано
  def chunked_insert(model, rows, unique_by: nil, chunk: 2_000)
    return if rows.blank?

    # Список колонок модели (без id)
    cols = model.column_names.map(&:to_sym) - [:id]
    has_created = cols.include?(:created_at)
    has_updated = cols.include?(:updated_at)

    # Какие колонки — массивы (Postgres array)
    columns_hash = model.columns_hash
    array_cols = cols.select do |c|
      ch = columns_hash[c.to_s]
      ch && ch.respond_to?(:array) && ch.array
    end

    # Нормализуем ключи хэшей к символам
    rows = rows.map { |h| h.transform_keys(&:to_sym) }

    # Базовый набор ключей: объединение ключей всех записей, но только те, что есть в колонках модели
    base_keys = (rows.flat_map(&:keys).uniq & cols)
    # Гарантируем наличие таймстампов, если такие колонки существуют
    base_keys |= [:created_at] if has_created
    base_keys |= [:updated_at] if has_updated

    rows.each_slice(chunk) do |slice|
      now = Time.current

      payload = slice.map do |h|
        base_keys.each_with_object({}) do |k, acc|
          if (k == :created_at && has_created) || (k == :updated_at && has_updated)
            acc[k] = now
          else
            v = h.key?(k) ? h[k] : nil
            v = [] if v.nil? && array_cols.include?(k) # для array-колонок — [] вместо nil
            acc[k] = v
          end
        end
      end

      if unique_by
        model.upsert_all(payload, unique_by: unique_by)
      else
        model.insert_all(payload)
      end
    end
  end
end
