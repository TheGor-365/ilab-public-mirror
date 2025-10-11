class CreateProductSidebarEntriesView < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1 FROM pg_matviews
          WHERE schemaname = 'public' AND matviewname = 'product_sidebar_entries'
        ) THEN
          EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS product_sidebar_entries CASCADE';
        ELSIF EXISTS (
          SELECT 1 FROM pg_views
          WHERE schemaname = 'public' AND viewname = 'product_sidebar_entries'
        ) THEN
          EXECUTE 'DROP VIEW IF EXISTS product_sidebar_entries CASCADE';
        END IF;
      END
      $$;
    SQL

    execute <<~SQL
      CREATE VIEW product_sidebar_entries AS
        SELECT pr.product_id, 'repair'::text AS kind, r.id AS entity_id, r.title AS label
          FROM product_repairs pr JOIN repairs r ON r.id=pr.repair_id
        UNION ALL
        SELECT pd.product_id, 'defect'::text, d.id, d.title
          FROM product_defects pd JOIN defects d ON d.id=pd.defect_id
        UNION ALL
        SELECT pm.product_id, 'mod'::text, m.id, m.name
          FROM product_mods pm JOIN mods m ON m.id=pm.mod_id
        UNION ALL
        SELECT psp.product_id, 'spare_part'::text, s.id, s.name
          FROM product_spare_parts psp JOIN spare_parts s ON s.id=psp.spare_part_id;
    SQL
  end

  def down
    execute "DROP VIEW IF EXISTS product_sidebar_entries;"
  end
end
