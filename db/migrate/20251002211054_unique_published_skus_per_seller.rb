class UniquePublishedSkusPerSeller < ActiveRecord::Migration[7.1]
  def change
    add_index :products, [:seller_id, :sku_id],
      unique: true,
      where: "state <> 0",
      name: "idx_products_unique_published_sku_per_seller"
  end
end
