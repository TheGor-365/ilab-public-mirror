class HardenProductsWithSkuCheckAndTrigger < ActiveRecord::Migration[7.1]
  def up
    # 0) На всякий случай подчистим одноимённые констрейнты
    execute <<~SQL
      ALTER TABLE products
        DROP CONSTRAINT IF EXISTS products_generation_required_for_non_draft,
        DROP CONSTRAINT IF EXISTS products_sku_required_for_non_draft;
    SQL

    # 1) Новый CHECK: для не-draft обязателен sku_id
    execute <<~SQL
      ALTER TABLE products
      ADD CONSTRAINT products_sku_required_for_non_draft
      CHECK (state = 0 OR sku_id IS NOT NULL);
    SQL

    # 2) Функция синхронизации variant-полей из SKU
    execute <<~SQL
      CREATE OR REPLACE FUNCTION set_product_variant_from_sku()
      RETURNS trigger
      LANGUAGE plpgsql
      AS $$
      BEGIN
        IF NEW.sku_id IS NULL THEN
          RETURN NEW;
        END IF;

        SELECT s.generation_id, s.phone_id, s.storage, s.color
          INTO NEW.generation_id, NEW.phone_id, NEW.storage, NEW.color
        FROM skus s
        WHERE s.id = NEW.sku_id;

        RETURN NEW;
      END;
      $$;
    SQL

    # 3) Триггер на INSERT/UPDATE sku_id
    execute <<~SQL
      DROP TRIGGER IF EXISTS trg_products_sync_variant_from_sku ON products;
      CREATE TRIGGER trg_products_sync_variant_from_sku
      BEFORE INSERT OR UPDATE OF sku_id ON products
      FOR EACH ROW
      EXECUTE FUNCTION set_product_variant_from_sku();
    SQL
  end

  def down
    # Откат: убираем триггер/функцию и возвращаем старый generation-CHECK (если его нет)
    execute "DROP TRIGGER IF EXISTS trg_products_sync_variant_from_sku ON products;"
    execute "DROP FUNCTION IF EXISTS set_product_variant_from_sku();"

    execute <<~SQL
      ALTER TABLE products
        DROP CONSTRAINT IF EXISTS products_sku_required_for_non_draft;
    SQL

    execute <<~SQL
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint
          WHERE conname = 'products_generation_required_for_non_draft'
            AND conrelid = 'products'::regclass
        ) THEN
          EXECUTE $ddl$
            ALTER TABLE products
            ADD CONSTRAINT products_generation_required_for_non_draft
            CHECK (state = 0 OR generation_id IS NOT NULL)
          $ddl$;
        END IF;
      END
      $$;
    SQL
  end
end
