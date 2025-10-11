# lib/tasks/sku.rake
namespace :skus do
  desc "Создать недостающие SKU из Generation.storage_options × color_options × phones. Аргументы: [family] или ENV FAMILY=..."
  task :fill_missing, [:family] => :environment do |t, args|
    family = (args[:family] || ENV['FAMILY']).to_s.presence
    gens = family ? Generation.where(family: family) : Generation.all

    created = 0
    gens.find_each do |g|
      storages = Array(g.storage_options).compact_blank
      colors   = Array(g.color_options).compact_blank
      next if storages.empty? || colors.empty?

      # берём просто id телефонов, чтобы не держать объекты в памяти
      phone_ids = Phone.where(generation_id: g.id).pluck(:id)
      phone_ids = [nil] if phone_ids.empty? # создаём SKU и без phone_id, если телефонов нет

      phone_ids.each do |phone_id|
        storages.each do |s|
          colors.each do |c|
            attrs = { generation_id: g.id, phone_id: phone_id, storage: s, color: c }
            next if Sku.exists?(attrs)
            Sku.create!(attrs)
            created += 1
          end
        end
      end
    end

    puts "✓ Готово. Создано SKU: #{created}"
  end
end
