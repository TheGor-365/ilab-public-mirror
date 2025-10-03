class AddBtreeIndexesForSidebar < ActiveRecord::Migration[7.1]
  def change
    add_idx(:product_repairs,      :product_id, :idx_product_repairs_product_id)
    add_idx(:product_defects,      :product_id, :idx_product_defects_product_id)
    add_idx(:product_mods,         :product_id, :idx_product_mods_product_id)
    add_idx(:product_spare_parts,  :product_id, :idx_product_spare_parts_product_id)
  end

  private

  def add_idx(table, column, name)
    add_index(table, column, name: name) unless index_exists?(table, column, name: name)
  end
end
