class AddCheckGenerationForActiveProducts < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      ALTER TABLE products
      DROP CONSTRAINT IF EXISTS products_generation_required_for_non_draft;
    SQL

    # Ставим невалидационное ограничение (не проверяет прошлые строки немедленно)
    execute <<~SQL
      ALTER TABLE products
      ADD CONSTRAINT products_generation_required_for_non_draft
      CHECK (state = 0 OR generation_id IS NOT NULL) NOT VALID;
    SQL

    # Минимальный бэку заполнения: переводим "битые" записи в draft
    execute <<~SQL
      UPDATE products
      SET state = 0
      WHERE generation_id IS NULL AND state <> 0;
    SQL

    # Теперь валидируем
    execute <<~SQL
      ALTER TABLE products
      VALIDATE CONSTRAINT products_generation_required_for_non_draft;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE products
      DROP CONSTRAINT IF EXISTS products_generation_required_for_non_draft;
    SQL
  end
end
