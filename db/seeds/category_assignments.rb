def categorize_family!(slug, family)
  cat = Category.find_by!(slug: slug)
  Generation.where(family: family).find_each do |gen|
    Categorization.where(
      category_id: cat.id,
      subject_type: 'Generation',
      subject_id: gen.id
    ).first_or_create!
  end
end

# Корни (как было)
categorize_family!('iphone',        'iPhone')
categorize_family!('ipad',          'iPad')
categorize_family!('mac',           'Mac')
categorize_family!('apple-watch',   'Apple Watch')
categorize_family!('ipod',          'iPod')

# Листовые ветки по реальным семействам
categorize_family!('airpods',       'AirPods')
categorize_family!('speakers',      'HomePod')    # попадает и HomePod, и HomePod mini, и HomePod (2nd gen)
categorize_family!('apple-tv',      'Apple TV')
categorize_family!('vision-pro',    'Vision Pro')
categorize_family!('displays',      'Display')
categorize_family!('networking',    'Networking')

# Общая ветка аксессуаров — чтобы мыши/клавы/пульты/кабели с family: Accessories тоже были видны
categorize_family!('accessories',   'Accessories')

puts "[seeds] category assignments done"
