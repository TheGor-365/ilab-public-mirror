# frozen_string_literal: true
#
# Usage:
#   bin/rails ilab:sanity
#   → Проверяет, что товары не «пустышки», и по каждому семейству есть активные товары.

namespace :ilab do
  desc "Проверка витрины на 'пустышки' + наличие активных товаров по семействам"
  task :sanity => :environment do
    state_active =
      if Product.respond_to?(:states) && (Product.states.key?("active") || Product.states.key?(:active))
        Product.states["active"] || Product.states[:active]
      else
        col = Product.columns_hash["state"]
        col&.type == :integer ? 0 : "active"
      end

    bad = Product.left_joins(:generation)
                 .where(generations: { id: nil })
                 .or(Product.where(storage: [nil,""]))
                 .or(Product.where(color: [nil,""]))
                 .or(Product.where("price <= 0"))

    if bad.exists?
      puts "⚠️ Найдены проблемные товары: #{bad.count}"
      bad.limit(50).pluck(:id, :name, :generation_id, :storage, :color, :price).each { |row| p row }
      exit(1)
    end

    fams = Generation.distinct.order(:family).pluck(:family)
    missing = []
    fams.each do |fam|
      cnt = Product.joins("JOIN generations g ON g.id=products.generation_id")
                   .where("g.family = ?", fam)
                   .where(products: { state: state_active })
                   .count
      puts "#{fam.ljust(14)} active products: #{cnt}"
      missing << fam if cnt.zero?
    end

    if missing.any?
      puts "⚠️ В этих семействах нет активных товаров: #{missing.join(', ')}"
      exit(1)
    else
      puts "✓ Витрина выглядит здоровой."
    end
  end
end
