class AddGenerationToCategories < ActiveRecord::Migration[7.1]
  def up
    add_reference :categories, :generation, index: true, foreign_key: true unless column_exists?(:categories, :generation_id)

    if column_exists?(:categories, :device_type) && column_exists?(:categories, :device_id)
      execute <<~SQL
        UPDATE categories c
        SET generation_id = CASE
          WHEN c.device_type = 'Generation' THEN c.device_id
          WHEN c.device_type = 'Phone'      THEN (SELECT generation_id FROM phones WHERE id = c.device_id)
          ELSE c.generation_id
        END
        WHERE c.generation_id IS NULL;
      SQL
    end

    add_index :categories, [:generation_id, :heading],
              unique: true,
              where: "generation_id IS NOT NULL",
              name: "idx_categories_on_generation_heading_unique"
  end

  def down
    remove_index :categories, name: "idx_categories_on_generation_heading_unique" rescue nil
    remove_reference :categories, :generation, foreign_key: true rescue nil
  end
end
