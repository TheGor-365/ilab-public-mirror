# app/services/skus/fill_missing.rb
module Skus
  class FillMissing
    def self.call(family: nil)
      gens = family.present? ? Generation.where(family: family) : Generation.all
      created = 0

      gens.find_each do |g|
        storages = Array(g.storage_options).compact_blank
        colors   = Array(g.color_options).compact_blank
        next if storages.empty? || colors.empty?

        phone_ids = Phone.where(generation_id: g.id).pluck(:id)
        phone_ids = [nil] if phone_ids.empty?

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

      created
    end
  end
end
