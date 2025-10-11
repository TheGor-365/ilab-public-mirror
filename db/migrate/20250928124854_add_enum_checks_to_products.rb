class AddEnumChecksToProducts < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      ALTER TABLE products
      ADD CONSTRAINT products_state_enum CHECK (state IN (0,1,2,3,4))
    SQL
    execute <<~SQL
      ALTER TABLE products
      ADD CONSTRAINT products_condition_enum CHECK (condition IN (0,1,2,3))
    SQL
  end

  def down
    execute "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_state_enum"
    execute "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_condition_enum"
  end
end
