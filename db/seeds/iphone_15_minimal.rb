# frozen_string_literal: true

def col?(table, col)
  ActiveRecord::Base.connection.column_exists?(table, col)
end

def has_assoc?(klass, name)
  klass.reflect_on_association(name).present?
end

def upsert_generation!(title)
  gen = Generation.find_or_initialize_by(title: title)
  gen.family ||= 'iPhone'
  gen.save! if gen.changed?
  gen
end

def upsert_phone!(model_title:, generation:)
  # Всегда создаём/обновляем С УЖЕ УСТАНОВЛЕННЫМ generation_id до первого save!
  phone = Phone.where(model_title: model_title).first

  if phone
    phone.update!(model_title: model_title, generation_id: generation.id)
  else
    # если есть колонки images/videos — положим пустые массивы
    base = { model_title: model_title, generation_id: generation.id }
    base[:model_overview] = ''  if Phone.column_names.include?('model_overview')
    base[:images]         = []  if Phone.column_names.include?('images')
    base[:videos]         = []  if Phone.column_names.include?('videos')

    Phone.create!(base)
    phone = Phone.find_by!(model_title: model_title)
  end

  # Обратная связь (если поддерживается)
  if generation.respond_to?(:phone_id) && generation.phone_id != phone.id
    generation.update!(phone_id: phone.id)
  elsif generation.respond_to?(:phone) && generation.phone != phone
    generation.update!(phone: phone)
  end

  phone
end

# --- iPhone 15 --------------------------------------------------------------
gen15 = upsert_generation!("iPhone 15")
ph15  = upsert_phone!(model_title: "iPhone 15", generation: gen15)

# --- iPhone 15 Pro ----------------------------------------------------------
gen15pro = upsert_generation!("iPhone 15 Pro")
ph15pro  = upsert_phone!(model_title: "iPhone 15 Pro", generation: gen15pro)

puts "Seeded:"
puts "  Generation 15:     #{gen15&.id} / #{gen15&.try(:title)}"
puts "  Phone 15:          #{ph15&.id} / #{ph15&.try(:model_title)}"
puts "  Generation 15 Pro: #{gen15pro&.id} / #{gen15pro&.try(:title)}"
puts "  Phone 15 Pro:      #{ph15pro&.id} / #{ph15pro&.try(:model_title)}"
