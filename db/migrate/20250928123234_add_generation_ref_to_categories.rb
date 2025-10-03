class AddGenerationRefToCategories < ActiveRecord::Migration[7.1]
  def up
    add_reference :categories, :generation, foreign_key: true, index: true

    # Мягкое наполнение из текущего полиморфизма (если device указывался как Generation)
    execute <<~SQL
      UPDATE categories
      SET generation_id = device_id
      WHERE device_type = 'Generation' AND generation_id IS NULL
    SQL

    # На первом шаге NOT NULL не ставим — дадим системе пожить.
    # Через релиз можно будет включить:
    # change_column_null :categories, :generation_id, false
  end

  def down
    remove_reference :categories, :generation, index: true, foreign_key: true
  end
end
