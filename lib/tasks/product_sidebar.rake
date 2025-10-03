# frozen_string_literal: true
#
# Usage:
#   bin/rails product_sidebar:recreate_view
#     → Дропает MVIEW/VIEW если есть и создаёт обычный VIEW product_sidebar_entries.
#
#   bin/rails product_sidebar:refresh
#     → Обновляет материализованную вьюху, если она реально материализованная.

namespace :product_sidebar do
  desc "Re-create as plain VIEW (drops MV if present)"
  task recreate_view: :environment do
    c = ActiveRecord::Base.connection

    c.execute <<~SQL
      DO $$
      BEGIN
        IF EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname='product_sidebar_entries') THEN
          EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS product_sidebar_entries CASCADE';
        ELSIF EXISTS (SELECT 1 FROM pg_views WHERE viewname='product_sidebar_entries') THEN
          EXECUTE 'DROP VIEW IF EXISTS product_sidebar_entries CASCADE';
        END IF;
      END
      $$;
    SQL

    c.execute <<~SQL
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

    puts "Plain VIEW product_sidebar_entries recreated."
  end

  desc "Refresh materialized view product_sidebar_entries (if it exists)"
  task refresh: :environment do
    c = ActiveRecord::Base.connection
    is_mv = c.select_value("SELECT EXISTS (SELECT 1 FROM pg_matviews WHERE matviewname='product_sidebar_entries')").in?([true, 't', 'true'])
    if is_mv
      c.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY product_sidebar_entries")
      puts "MVIEW refreshed"
    else
      abort "product_sidebar_entries сейчас не materialized view. Сначала прогоняй миграции или product_sidebar:recreate_view."
    end
  end
end
