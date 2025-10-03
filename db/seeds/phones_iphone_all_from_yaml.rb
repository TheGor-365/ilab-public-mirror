require 'yaml'

def upsert_generation_from_row!(row)
  title  = row['generation_title'] || row['title'] || row['generation'] || row['model']
  family = row['family'] || 'iPhone'
  raise "No generation title in row: #{row.inspect}" if title.blank?

  g = Generation.find_or_initialize_by(title: title)
  g.family           = family
  g.released_on      = row['released_on'] if row['released_on']
  g.discontinued_on  = row['discontinued_on'] if row['discontinued_on']
  g.aliases          = row['aliases'] || []
  g.storage_options  = row['storage_options'] || []
  g.color_options    = row['color_options'] || []
  g.save!
  g
end

def upsert_phone_for_generation!(gen)
  ph = Phone.find_or_initialize_by(model_title: gen.title)
  if ph.new_record?
    ph.model_overview = ''
    ph.images = []
    ph.videos = []
  end

  if ph.respond_to?(:generation=)
    ph.generation = gen
  elsif ph.respond_to?(:generation_id)
    ph.generation_id = gen.id
  end

  ph.save!(validate: false)
  ph
end

path = Rails.root.join('db', 'catalog', 'apple', 'iphones.yml')
rows = YAML.safe_load(File.read(path))

created = 0
rows.each do |row|
  gen = upsert_generation_from_row!(row)
  upsert_phone_for_generation!(gen)
  created += 1
end

# для двусторонней связи (если в Generation есть belongs_to :phone)
if Generation.column_names.include?('title')
  rows.each do |row|
    title = row['generation_title'] || row['title']
    gen = Generation.find_by(title: title)
    next unless gen

    if gen.respond_to?(:phone) && gen.phone.nil?
      phone = Phone.find_by(model_title: gen.title)
      gen.update!(phone: phone) if phone
    elsif gen.respond_to?(:phone_id) && gen.phone_id.nil?
      phone = Phone.find_by(model_title: gen.title)
      gen.update!(phone_id: phone.id) if phone
    end
  end
end

puts "[seeds] Imported/ensured ALL iPhone generations from YAML: #{created} rows."
