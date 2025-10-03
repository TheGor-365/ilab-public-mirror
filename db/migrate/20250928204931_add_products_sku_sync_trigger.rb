class AddProductsSkuSyncTrigger < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION fn_products_sync_variant_from_sku()
      RETURNS trigger AS $$
      BEGIN
        IF NEW.sku_id IS NOT NULL THEN
          SELECT s.generation_id, s.phone_id, s.storage, s.color
            INTO NEW.generation_id, NEW.phone_id, NEW.storage, NEW.color
          FROM skus s
          WHERE s.id = NEW.sku_id;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;

      DROP TRIGGER IF EXISTS trg_products_sync_variant_on_insert ON products;
      CREATE TRIGGER trg_products_sync_variant_on_insert
      BEFORE INSERT ON products
      FOR EACH ROW
      EXECUTE FUNCTION fn_products_sync_variant_from_sku();

      DROP TRIGGER IF EXISTS trg_products_sync_variant_on_update ON products;
      CREATE TRIGGER trg_products_sync_variant_on_update
      BEFORE UPDATE OF sku_id ON products
      FOR EACH ROW
      EXECUTE FUNCTION fn_products_sync_variant_from_sku();
    SQL
  end

  def down
    execute <<~SQL
      DROP TRIGGER IF EXISTS trg_products_sync_variant_on_insert ON products;
      DROP TRIGGER IF EXISTS trg_products_sync_variant_on_update ON products;
      DROP FUNCTION IF EXISTS fn_products_sync_variant_from_sku();
    SQL
  end
end
