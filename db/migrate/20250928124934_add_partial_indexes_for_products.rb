class AddPartialIndexesForProducts < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :generation_id,
      where: "state <> 0",
      name: "idx_products_generation_for_non_draft"
    add_index :products, [:state, :price],
      where: "price IS NOT NULL",
      name: "idx_products_state_price"
  end
end
