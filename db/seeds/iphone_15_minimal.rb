# frozen_string_literal: true

# Хелперы
def col?(table, col)
  ActiveRecord::Base.connection.column_exists?(table, col)
end

def has_assoc?(klass, name)
  klass.reflect_on_association(name).present?
end

def upsert_generation!(title)
  if defined?(Generation)
    # создаём/находим поколение без требований к phone
    gen = Generation.where(title: title).first
    return gen if gen

    # если в generations есть not null колонки — добавь дефолты здесь при необходимости
    Generation.create!(title: title)
  end
end

def upsert_phone!(model_title:, generation: nil)
  return unless defined?(Phone)

  # не используем find_or_create_by! с блоком — он не передаст зависимость в where
  ph = Phone.where(model_title: model_title).first || Phone.new(model_title: model_title)

  # если у Phone есть связь с generation — выставим
  if has_assoc?(Phone, :generation) && ph.respond_to?(:generation=) && generation
    ph.generation ||= generation
  end

  ph.save! unless ph.persisted?
  ph
end

# --- iPhone 15 --------------------------------------------------------------
gen15 = upsert_generation!("iPhone 15")
ph15  = upsert_phone!(model_title: "iPhone 15", generation: gen15)

# если у Generation есть связь на phone — соединим в обратную сторону
if gen15 && gen15.respond_to?(:phone=) && gen15.phone.nil?
  gen15.update!(phone: ph15)
elsif gen15 && col?(:generations, :phone_id) && gen15.respond_to?(:phone_id) && gen15.phone_id.nil?
  gen15.update!(phone_id: ph15.id)
end

# --- iPhone 15 Pro ----------------------------------------------------------
gen15pro = upsert_generation!("iPhone 15 Pro")
ph15pro  = upsert_phone!(model_title: "iPhone 15 Pro", generation: gen15pro)

if gen15pro && gen15pro.respond_to?(:phone=) && gen15pro.phone.nil?
  gen15pro.update!(phone: ph15pro)
elsif gen15pro && col?(:generations, :phone_id) && gen15pro.respond_to?(:phone_id) && gen15pro.phone_id.nil?
  gen15pro.update!(phone_id: ph15pro.id)
end

puts "Seeded:"
puts "  Generation 15:     #{gen15&.id} / #{gen15&.try(:title)}"
puts "  Phone 15:          #{ph15&.id} / #{ph15&.try(:model_title)}"
puts "  Generation 15 Pro: #{gen15pro&.id} / #{gen15pro&.try(:title)}"
puts "  Phone 15 Pro:      #{ph15pro&.id} / #{ph15pro&.try(:model_title)}"
