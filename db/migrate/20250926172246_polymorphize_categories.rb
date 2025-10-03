class PolymorphizeCategories < ActiveRecord::Migration[7.1]
  def up
    add_column :categories, :device_type, :string
    add_column :categories, :device_id,   :bigint

    add_index  :categories, [:device_type, :device_id], name: "idx_categories_device_poly"
    add_index  :categories, [:device_type, :device_id, :heading], unique: true, name: "ux_categories_device_heading"

    # backfill из legacy phone_id
    execute <<~SQL
      UPDATE categories
         SET device_type = 'Phone',
             device_id   = phone_id
       WHERE phone_id IS NOT NULL
         AND (device_type IS NULL OR device_id IS NULL);
    SQL

    # phone_id оставляем для обратной совместимости, но делаем NULL-able
    change_column_null :categories, :phone_id, true
  end

  def down
    remove_index  :categories, name: "ux_categories_device_heading"
    remove_index  :categories, name: "idx_categories_device_poly"
    remove_column :categories, :device_type
    remove_column :categories, :device_id
    change_column_null :categories, :phone_id, false
  end
end
