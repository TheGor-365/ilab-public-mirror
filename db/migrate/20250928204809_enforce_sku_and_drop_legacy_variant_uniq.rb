class EnforceSkuAndDropLegacyVariantUniq < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    # 1) требуем SKU для не-черновиков
    unless check_constraint_exists?(:products, name: "products_sku_required_for_non_draft")
      add_check_constraint :products,
        "state = 0 OR sku_id IS NOT NULL",
        name: "products_sku_required_for_non_draft"
    end

    # 2) удаляем устаревшую уникалку по (seller + generation/model/phone/storage/color)
    if index_exists?(:products, [:seller_id, :generation_id, :model_id, :phone_id, :storage, :color],
                     name: "index_products_on_seller_and_variant")
      remove_index :products,
                   name: "index_products_on_seller_and_variant",
                   algorithm: :concurrently
    end
  end

  def down
    # откатываем CHECK
    remove_check_constraint :products, name: "products_sku_required_for_non_draft" rescue nil

    # возвращаем уникалку (на всякий случай)
    unless index_exists?(:products, [:seller_id, :generation_id, :model_id, :phone_id, :storage, :color],
                         name: "index_products_on_seller_and_variant")
      add_index :products,
                [:seller_id, :generation_id, :model_id, :phone_id, :storage, :color],
                unique: true,
                name: "index_products_on_seller_and_variant",
                algorithm: :concurrently
    end
  end
end
