# frozen_string_literal: true

namespace :ilab do
  namespace :catalog do
    namespace :coverage do
      desc "Покрытие вариантов (storage×color) по семейству (iphones)"
      task :variants, [:scope] => :environment do |_, args|
        scope = (args[:scope].presence || "iphones").to_s

        case scope
        when "iphones"
          fam = "iPhone"
        else
          abort "Unsupported scope=#{scope}"
        end

        gen_cols    = Generation.column_names
        phone_cols  = Phone.column_names
        prod_cols   = Product.column_names
        model_cols  = Model.column_names

        # Проверим, что есть ключевые поля в products
        unless prod_cols.include?("storage") && prod_cols.include?("color")
          abort "products.storage/color columns are required. Found: #{prod_cols.inspect}"
        end

        gens = Generation.where(family: fam).order(:released_on, :title)
        total_expected = 0
        total_actual   = 0
        gaps = []

        gens.find_each do |g|
          storages = (g.has_attribute?(:storage_options) ? g.storage_options : []) || []
          colors   = (g.has_attribute?(:color_options)   ? g.color_options   : []) || []
          expected = storages.product(colors).map { |s, c| [norm(s), norm(c)] }

          total_expected += expected.size

          # какие продукты уже есть для этого поколения
          rel = Product.all
          rel = rel.where(generation_id: g.id) if prod_cols.include?("generation_id")
          if prod_cols.include?("model_id")
            # берём любой(первый) базовый model_id для титула поколения
            m = if model_cols.include?('phone_id')
                  Model.joins(:phone).where(title: g.title, phones: { generation_id: g.id }).first
                else
                  Model.where(title: g.title).first
                end
            rel = rel.where(model_id: m.id) if m
          end

          actual = rel.pluck(:storage, :color).map { |s, c| [norm(s), norm(c)] }
          total_actual += actual.size

          missing = expected - actual
          unless missing.empty?
            gaps << { generation: g.title, missing: missing }
          end
        end

        puts "== Variants coverage for #{fam} =="
        puts "Expected products: #{total_expected}"
        puts "Actual   products: #{total_actual}"
        puts "Gaps generations: #{gaps.size}"
        gaps.first(20).each do |g|
          puts "  #{g[:generation]} — missing #{g[:missing].size} variants"
          g[:missing].first(10).each { |(s,c)| puts "    - #{s} / #{c}" }
        end
        puts "Tip: run `bin/rails \"ilab:catalog:materialize_products[#{scope}]\"` to create missing."
      end
    end

    desc "Материализация products по storage×color (iphones)"
    task :materialize_products, [:scope] => :environment do |_, args|
      scope = (args[:scope].presence || "iphones").to_s
      fam   = scope == "iphones" ? "iPhone" : abort("Unsupported scope=#{scope}")

      prod_cols  = Product.column_names
      model_cols = Model.column_names

      unless prod_cols.include?("storage") && prod_cols.include?("color")
        abort "products.storage/color columns are required. Found: #{prod_cols.inspect}"
      end

      created = 0

      Generation.where(family: fam).order(:released_on, :title).find_each do |g|
        storages = (g.has_attribute?(:storage_options) ? g.storage_options : []) || []
        colors   = (g.has_attribute?(:color_options)   ? g.color_options   : []) || []
        next if storages.empty? || colors.empty?

        # найдём модель-«эталон» для поколения
        model = if model_cols.include?('phone_id')
                  Model.joins(:phone).where(title: g.title, phones: { generation_id: g.id }).first
                else
                  Model.where(title: g.title).first
                end

        # если модели нет — создадим на лету (перестраховка)
        unless model
          phone = if Phone.column_names.include?('generation_id')
                    Phone.find_or_create_by!(generation_id: g.id, model_title: g.title)
                  else
                    Phone.find_or_create_by!(model_title: g.title)
                  end
          model = Model.find_or_create_by!(title: g.title, phone_id: (phone.id if Model.column_names.include?('phone_id')))
        end

        storages.product(colors).each do |s, c|
          s_key = norm(s)
          c_key = norm(c)

          attrs = { storage: s_key, color: c_key }
          attrs[:generation_id] = g.id    if prod_cols.include?('generation_id')
          attrs[:model_id]      = model.id if prod_cols.include?('model_id')
          attrs[:phone_id]      = model.phone_id if prod_cols.include?('phone_id') && model.respond_to?(:phone_id)

          # Ищем «похожий» продукт
          rel = Product.where(storage: s_key, color: c_key)
          rel = rel.where(generation_id: g.id) if prod_cols.include?('generation_id')
          rel = rel.where(model_id: model.id)  if prod_cols.include?('model_id')
          rel = rel.where(phone_id: attrs[:phone_id]) if prod_cols.include?('phone_id') && attrs[:phone_id].present?

          unless rel.exists?
            Product.create!(attrs)
            created += 1
          end
        end
      end

      puts "✓ materialize_products[#{scope}] — created: #{created}"
    end
  end
end

# helpers
def norm(v)
  v.to_s.strip.gsub(/\s+/, ' ')
end
