# frozen_string_literal: true

require 'yaml'
require 'date'

PERMITTED_YAML_CLASSES = [Date, Time].freeze

namespace :ilab do
  namespace :catalog do
    desc "Импорт каталога (scope: iphones|all)"
    task :import, [:scope] => :environment do |_, args|
      scope    = (args[:scope].presence || "all").to_s
      importer = CatalogImporter.new(logger: Logger.new($stdout))

      def import_yaml(importer, family, relpath)
        path = Rails.root.join("db/catalog/apple", relpath)
        raise "YAML not found: #{path}" unless File.exist?(path)
        importer.import!(family: family, path: path)
      end

      if %w[iphones all].include?(scope)
        import_yaml(importer, "iPhone", "iphones.yml")
      end

      puts "iPhone generations in DB now: #{Generation.where(family: 'iPhone').count}"
      puts "✅ ilab:catalog:import[#{scope}] done."
    end

    desc "Покрытие каталога: сверка YAML ↔ БД"
    task :coverage, [:scope] => :environment do |_, args|
      scope = (args[:scope].presence || "iphones").to_s

      case scope
      when "iphones"
        path = Rails.root.join("db/catalog/apple/iphones.yml")
        raise "YAML not found: #{path}" unless File.exist?(path)

        raw = File.read(path)
        yaml = Psych.safe_load(
          raw,
          permitted_classes: PERMITTED_YAML_CLASSES,
          permitted_symbols: [],
          aliases: true
        )

        unless yaml.is_a?(Array)
          raise ArgumentError, "YAML must be an Array of rows, got: #{yaml.class}"
        end

        yaml_rows = yaml.map { |row| row.transform_keys(&:to_s) }
        in_yaml = yaml_rows
                    .select { |x| x["family"].to_s == "iPhone" }
                    .map    { |x| x["generation_title"].to_s }
                    .reject(&:blank?)
                    .uniq
                    .sort

        in_db = Generation.where(family: "iPhone").pluck(:title).map(&:to_s).uniq.sort

        missing_in_db = in_yaml - in_db
        extra_in_db   = in_db - in_yaml

        puts "YAML iPhones: #{in_yaml.size}"
        puts "DB   iPhones: #{in_db.size}"

        puts "Missing in DB (need import): #{missing_in_db.size}"
        missing_in_db.first(50).each { |t| puts "  - #{t}" }

        puts "Extra in DB (not in YAML): #{extra_in_db.size}"
        extra_in_db.first(50).each { |t| puts "  - #{t}" }
      else
        puts "Add support for scope=#{scope} later."
      end
    end

    desc "Бэкфилл products по name → связи (аккуратно)"
    task :backfill_products_by_name => :environment do
      updated = 0
      Product.where(generation_id: nil).find_each do |p|
        ctx = p.resolve_relations_by_name
        next unless ctx[:generation]

        p.update_columns(
          generation_id: ctx[:generation].id,
          phone_id: ctx[:phone]&.id
        )
        updated += 1
      end
      puts "✓ backfilled products: #{updated}"
    end
  end
end
