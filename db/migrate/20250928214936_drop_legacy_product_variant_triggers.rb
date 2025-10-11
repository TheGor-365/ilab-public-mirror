class DropLegacyProductVariantTriggers < ActiveRecord::Migration[7.1]
  def up
    execute "DROP TRIGGER IF EXISTS trg_products_sync_variant_on_insert ON products;"
    execute "DROP TRIGGER IF EXISTS trg_products_sync_variant_on_update ON products;"
  end

  def down
    # Ничего не восстанавливаем — функционал теперь покрыт триггером trg_products_sync_variant_from_sku
  end
end
