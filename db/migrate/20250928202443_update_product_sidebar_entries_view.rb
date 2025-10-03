class UpdateProductSidebarEntriesView < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE VIEW product_sidebar_entries AS
      WITH unioned AS (
        -- 1) Каталог через SKU
        SELECT p.id AS product_id, sse.kind, sse.item_id AS entity_id, sse.label, 1 AS src_prio
        FROM products p
        JOIN skus s ON s.id = p.sku_id
        JOIN sku_sidebar_entries sse ON sse.sku_id = s.id

        UNION ALL
        -- 2) Витрина-override: repairs
        SELECT p.id, 'repair'::text, r.id AS entity_id, r.title, 0 AS src_prio
        FROM products p
        JOIN product_repairs pr ON pr.product_id = p.id
        JOIN repairs r ON r.id = pr.repair_id

        UNION ALL
        -- 3) Витрина-override: defects
        SELECT p.id, 'defect'::text, d.id AS entity_id, d.title, 0 AS src_prio
        FROM products p
        JOIN product_defects pd ON pd.product_id = p.id
        JOIN defects d ON d.id = pd.defect_id

        UNION ALL
        -- 4) Витрина-override: mods
        SELECT p.id, 'mod'::text, m.id AS entity_id, m.name, 0 AS src_prio
        FROM products p
        JOIN product_mods pm ON pm.product_id = p.id
        JOIN mods m ON m.id = pm.mod_id

        UNION ALL
        -- 5) Витрина-override: spare_parts
        SELECT p.id, 'spare_part'::text, sp.id AS entity_id, sp.name, 0 AS src_prio
        FROM products p
        JOIN product_spare_parts psp ON psp.product_id = p.id
        JOIN spare_parts sp ON sp.id = psp.spare_part_id
      )
      SELECT DISTINCT ON (product_id, kind, entity_id)
             product_id, kind, entity_id, label
      FROM unioned
      ORDER BY product_id, kind, entity_id, src_prio; -- 0 (витрина) выигрывает у 1 (каталог)
    SQL
  end

  def down
    execute "DROP VIEW IF EXISTS product_sidebar_entries;"
  end
end
