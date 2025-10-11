class AddSellerToProductsAndUpdateVariantIndex < ActiveRecord::Migration[7.1]
  def up
    add_reference :products, :seller, foreign_key: { to_table: :users }, null: true unless column_exists?(:products, :seller_id)

    if index_exists?(:products, [:storage, :color, :generation_id, :model_id, :phone_id], name: "index_products_on_variant_key", unique: true)
      remove_index :products, name: "index_products_on_variant_key"
    end

    add_index :products, [:seller_id, :generation_id, :model_id, :phone_id, :storage, :color],
              unique: true, name: "index_products_on_seller_and_variant"
  end

  def down
    remove_index :products, name: "index_products_on_seller_and_variant" if index_exists?(:products, name: "index_products_on_seller_and_variant")

    add_index :products, [:storage, :color, :generation_id, :model_id, :phone_id],
              unique: true, name: "index_products_on_variant_key" unless index_exists?(:products, [:storage, :color, :generation_id, :model_id, :phone_id], name: "index_products_on_variant_key")

    remove_reference :products, :seller, foreign_key: true if column_exists?(:products, :seller_id)
  end
end
