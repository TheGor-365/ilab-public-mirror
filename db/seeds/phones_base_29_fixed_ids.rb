# frozen_string_literal: true

# Этот сидер заменяет любые прямые insert_all! без generation_id.
# Он гарантированно найдёт/создаст поколение и вставит телефон с корректной FK.

# ---- ВАШИ ДАННЫЕ -------------------------------------------------------------
# Оставьте ваше содержимое PHONES_BASE_29 без изменений.
# Пример структуры:
# PHONES_BASE_29 = [
#   [1,  { title: "iPhone 4", released_on: Date.new(2010,6,24) }],
#   [2,  { title: "iPhone 4S", released_on: Date.new(2011,10,14) }],
#   ...
# ]
# -----------------------------------------------------------------------------

def _title_from(attrs)
  a = attrs.symbolize_keys
  a[:title] || a[:name] || a[:model] || a[:model_title] || a[:label]
end

def _family_from(_attrs)
  # Если у вас телефоны = iPhone, жёстко возвращаем 'iPhone'
  # (при необходимости поменяйте на вычисление из атрибутов)
  'iPhone'
end

def _ensure_generation_id!(attrs)
  title = _title_from(attrs)
  raise ArgumentError, "Не удалось определить название поколения для телефона: #{attrs.inspect}" if title.blank?

  family = _family_from(attrs)

  # Модель Generation должна существовать в проекте.
  # Если у Generation есть колонка family — заполним её.
  gen = Generation.find_or_create_by!(title:) do |g|
    g.family = family if g.respond_to?(:family) && g.family.blank?
  end
  gen.id
end

ActiveRecord::Base.transaction do
  list = if defined?(PHONES_BASE_29)
           PHONES_BASE_29
         else
           raise "Ожидалась константа PHONES_BASE_29 с данными телефонов"
         end

  rows = list.map do |fixed_id, attrs|
    attrs = attrs.symbolize_keys

    {
      id: fixed_id,
      generation_id: _ensure_generation_id!(attrs),
      created_at: Time.current,
      updated_at: Time.current
    }.merge(attrs.except(:id, :generation_id, :created_at, :updated_at))
  end

  # Можно и upsert_all, если есть уникальный индекс по id:
  # Phone.upsert_all(rows, unique_by: :primary_key)
  Phone.insert_all!(rows)
end
