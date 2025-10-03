class AddUniqueIndexOnProductsSellerSku < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :products, [:seller_id, :sku_id],
              unique: true,
              where: "sku_id IS NOT NULL",
              name: "ux_products_seller_id_sku_id",
              algorithm: :concurrently unless index_exists?(:products, [:seller_id, :sku_id], name: "ux_products_seller_id_sku_id")
  end

  def down
    remove_index :products, name: "ux_products_seller_id_sku_id" rescue nil
  end
end
