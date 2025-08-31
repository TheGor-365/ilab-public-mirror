# lib/tasks/ilab_catalog_variants.rake
# frozen_string_literal: true

namespace :ilab do
  namespace :catalog do
    namespace :coverage do
      desc "Материализовать витрину (storage×color) по семейству (iphones)"
      task :variants, [:scope] => :environment do |_, args|
        scope = (args[:scope].presence || "iphones").to_s
        fam   = scope == "iphones" ? "iPhone" : abort("Unsupported scope=#{scope}")

        created = 0

        Generation.by_family(fam).find_each do |g|
          phone = g.phone || Phone.find_or_create_by!(generation: g, model_title: g.title)
          base_model = Model.find_or_create_by!(generation: g, phone: phone, title: g.title)

          storages = Array(g.storage_options).presence || %w[64GB 128GB]
          colors   = Array(g.color_options).presence   || %w[Black Silver]

          storages.product(colors).each do |storage, color|
            attrs = {
              generation_id: g.id,
              phone_id:      phone.id,
              model_id:      base_model.id,
              storage:       storage,
              color:         color
            }

            # Уникальность варианта может мешать нескольким продавцам.
            # Здесь считаем, что витрину материализуем "одним SKU".
            p = Product.find_or_initialize_by(attrs)

            next if p.persisted?

            # простая формула цены: базовая 300 + надбавка за storage
            base_price = 300
            mult = storage.to_s[/\d+/].to_i / 64.0
            p.price = (base_price * [mult, 1.0].max).round(-1)

            p.description ||= "Refurbished #{g.title} • #{storage} • #{color}"
            p.currency    ||= "USD"
            p.state       ||= 0
            p.condition   ||= 1
            p.stock       ||= 1

            # Название соберёт before_validation, но подстрахуем отображение
            p.name = [g.title, storage, color].join(" ")

            p.save!
            created += 1
          end
        end

        puts "✓ materialize_products[#{scope}] — created: #{created}"
      end
    end
  end
end
