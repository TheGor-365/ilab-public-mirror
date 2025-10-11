class AddStoreFksAndIndexes < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :products, :generations unless foreign_key_exists?(:products, :generations)
    add_index :products, :generation_id      unless index_exists?(:products, :generation_id)
    add_index :products, :state              unless index_exists?(:products, :state)
    add_index :products, :price              unless index_exists?(:products, :price)
    add_index :generations, :family          unless index_exists?(:generations, :family)
  end
end
