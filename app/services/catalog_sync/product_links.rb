# frozen_string_literal: true
module CatalogSync
  class ProductLinks
    TAKE = {
      repairs: 2,
      defects: 2,
      mods:    2,
      spare_parts: 2
    }.freeze

    def initialize(product, take: TAKE)
      @product = product
      @take    = take
    end

    def call
      return unless @product&.sku_id

      # Источник знаний через SKU → generation → phones_*:
      domain_repair_ids = sql_ids(<<~SQL)
        SELECT DISTINCT r.id
        FROM skus s
        JOIN generations g ON g.id = s.generation_id
        JOIN phones ph ON ph.generation_id = g.id
        JOIN phones_repairs pr ON pr.phone_id = ph.id
        JOIN repairs r ON r.id = pr.repair_id
        WHERE s.id = #{@product.sku_id}
        LIMIT #{@take[:repairs] || 0}
      SQL

      domain_defect_ids = sql_ids(<<~SQL)
        SELECT DISTINCT d.id
        FROM skus s
        JOIN generations g ON g.id = s.generation_id
        JOIN phones ph ON ph.generation_id = g.id
        JOIN defects_phones dp ON dp.phone_id = ph.id
        JOIN defects d ON d.id = dp.defect_id
        WHERE s.id = #{@product.sku_id}
        LIMIT #{@take[:defects] || 0}
      SQL

      # Моды/запчасти доменно, если появится defects_mods/mods_repairs — можно аналогично
      # Пока только проставляем кеш, если пусто (на витрине уже есть по 2)
      attach(:repairs, domain_repair_ids, join: ProductRepair, fk: :repair_id)
      attach(:defects, domain_defect_ids, join: ProductDefect, fk: :defect_id)
      true
    end

    private

    def attach(kind, ids, join:, fk:)
      return if ids.empty?
      ids.each do |id|
        join.find_or_create_by!(product_id: @product.id, fk => id)
      end
    end

    def sql_ids(sql)
      ActiveRecord::Base.connection.select_values(sql).map(&:to_i)
    end
  end
end
