class ReworkCategoriesTaxonomy < ActiveRecord::Migration[7.1]
  def change
    change_column_null :categories, :phone_id, true
    add_column :categories, :slug, :string
    add_column :categories, :parent_id, :bigint
    add_index  :categories, :slug, unique: true
    add_index  :categories, :parent_id

    create_table :categorizations do |t|
      t.references :category, null: false, foreign_key: true
      t.string  :subject_type, null: false
      t.bigint  :subject_id,   null: false
      t.index [:subject_type, :subject_id]
      t.timestamps
    end
  end
end
