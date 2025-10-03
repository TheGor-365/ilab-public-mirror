class CreateProductLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :product_repairs do |t|
      t.references :product, null: false, foreign_key: true
      t.references :repair,  null: false, foreign_key: true
      t.timestamps
    end
    add_index :product_repairs, [:product_id, :repair_id], unique: true

    create_table :product_defects do |t|
      t.references :product, null: false, foreign_key: true
      t.references :defect,  null: false, foreign_key: true
      t.timestamps
    end
    add_index :product_defects, [:product_id, :defect_id], unique: true

    create_table :product_mods do |t|
      t.references :product, null: false, foreign_key: true
      t.references :mod,     null: false, foreign_key: true
      t.timestamps
    end
    add_index :product_mods, [:product_id, :mod_id], unique: true

    create_table :product_spare_parts do |t|
      t.references :product,    null: false, foreign_key: true
      t.references :spare_part, null: false, foreign_key: true
      t.timestamps
    end
    add_index :product_spare_parts, [:product_id, :spare_part_id], unique: true
  end
end
