class AddPriceCheckForNonDraftProducts < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      ALTER TABLE products
      ADD CONSTRAINT products_price_positive_for_non_draft
      CHECK (state = 0 OR (price IS NOT NULL AND price > 0))
    SQL
  end

  def down
    execute "ALTER TABLE products DROP CONSTRAINT IF EXISTS products_price_positive_for_non_draft"
  end
end
