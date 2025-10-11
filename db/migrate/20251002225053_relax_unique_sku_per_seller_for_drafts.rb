class RelaxUniqueSkuPerSellerForDrafts < ActiveRecord::Migration[7.1]
  def up
    # Сносим старый глобальный уникальный индекс, если есть
    if index_name_exists?(:products, "ux_products_seller_id_sku_id")
      remove_index :products, name: "ux_products_seller_id_sku_id"
    end

    # На всякий случай — если пробовали создавать новый индекс раньше
    if index_name_exists?(:products, "ux_products_seller_id_sku_id_not_draft")
      remove_index :products, name: "ux_products_seller_id_sku_id_not_draft"
    end

    # Новый частичный уникальный индекс: запрещает дубли только для НЕ-draft записей
    add_index :products, [:seller_id, :sku_id],
      unique: true,
      where: "sku_id IS NOT NULL AND state <> 0",
      name:  "ux_products_seller_id_sku_id_not_draft"
  end

  def down
    if index_name_exists?(:products, "ux_products_seller_id_sku_id_not_draft")
      remove_index :products, name: "ux_products_seller_id_sku_id_not_draft"
    end

    add_index :products, [:seller_id, :sku_id],
      unique: true,
      name: "ux_products_seller_id_sku_id"
  end
end
