# frozen_string_literal: true
#
# Usage:
#   bin/rails dev:seed_demo_data
#   → Импорт/бутстрап каталога, минимум 10 активных товаров на семейство,
#     привязка связей и быстрые проверки.

namespace :dev do
  desc "Полный цикл демо-данных: импорт/бутстрап, товары, связи, проверки"
  task seed_demo_data: :environment do
    puts "== dev:seed_demo_data =="

    # 1) Импорт каталога, где возможно
    Rake::Task["ilab:catalog:import_all"].invoke

    # 2) Если после импорта нет поколений — создаём демо
    if Generation.count.zero?
      puts "No generations after import – bootstrapping demo families..."
      Rake::Task["ilab:catalog:bootstrap_demo_families"].invoke
    end

    # 3) Гарантировать минимум 10 активных товаров по каждому семейству
    Rake::Task["ilab:catalog:ensure_min_products"].reenable
    Rake::Task["ilab:catalog:ensure_min_products"].invoke(10, "all")

    # 4) Привязать Repairs/Defects/Mods/SpareParts
    begin
      Rake::Task["demo:attach_links"].invoke
    rescue => e
      puts "demo:attach_links skipped (#{e.class}: #{e.message})"
    end

    # 5) Проверки
    begin
      Rake::Task["dev:check_demo_data"].invoke
    rescue => e
      puts "dev:check_demo_data skipped (#{e.class}: #{e.message})"
    end

    begin
      Rake::Task["ilab:sanity"].invoke
    rescue => e
      puts "ilab:sanity skipped (#{e.class}: #{e.message})"
    end

    puts "✔ dev:seed_demo_data done."
  end
end
