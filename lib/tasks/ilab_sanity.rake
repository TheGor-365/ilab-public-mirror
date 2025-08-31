# lib/tasks/ilab_sanity.rake
# frozen_string_literal: true

namespace :ilab do
  desc "Проверка витрины на 'пустышки'"
  task :sanity => :environment do
    bad = Product.left_joins(:generation)
                 .where(generations: { id: nil })
                 .or(Product.where(storage: [nil,""]))
                 .or(Product.where(color: [nil,""]))
                 .or(Product.where("price <= 0"))

    if bad.exists?
      puts "⚠️ Найдены проблемные товары: #{bad.count}"
      bad.limit(50).pluck(:id, :name, :generation_id, :storage, :color, :price).each { |row| p row }
      exit(1)
    else
      puts "✓ Витрина выглядит здоровой."
    end
  end
end
