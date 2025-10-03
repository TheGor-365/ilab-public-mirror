class CreateSkuSidebarEntriesView < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      CREATE OR REPLACE VIEW sku_sidebar_entries AS
      -- Каталоговые REPAIRS через phones -> phones_repairs
      SELECT s.id AS sku_id,
             'repair'::text AS kind,
             r.id AS item_id,
             r.title AS label
      FROM skus s
      JOIN generations g   ON g.id = s.generation_id
      JOIN phones ph       ON ph.generation_id = g.id
      JOIN phones_repairs pr ON pr.phone_id = ph.id
      JOIN repairs r       ON r.id = pr.repair_id

      UNION
      -- Каталоговые DEFECTS через phones -> defects_phones
      SELECT s.id AS sku_id,
             'defect'::text AS kind,
             d.id AS item_id,
             d.title AS label
      FROM skus s
      JOIN generations g   ON g.id = s.generation_id
      JOIN phones ph       ON ph.generation_id = g.id
      JOIN defects_phones dp ON dp.phone_id = ph.id
      JOIN defects d       ON d.id = dp.defect_id

      UNION
      -- Витринные MODS (оверрайд): всё, что уже привязано к продуктам этого SKU
      SELECT s.id AS sku_id,
             'mod'::text AS kind,
             m.id AS item_id,
             m.name AS label
      FROM skus s
      JOIN products p      ON p.sku_id = s.id
      JOIN product_mods pm ON pm.product_id = p.id
      JOIN mods m          ON m.id = pm.mod_id

      UNION
      -- Витринные SPARE PARTS (оверрайд)
      SELECT s.id AS sku_id,
             'spare_part'::text AS kind,
             sp.id AS item_id,
             sp.name AS label
      FROM skus s
      JOIN products p           ON p.sku_id = s.id
      JOIN product_spare_parts ps ON ps.product_id = p.id
      JOIN spare_parts sp       ON sp.id = ps.spare_part_id
      ;
    SQL
  end

  def down
    execute "DROP VIEW IF EXISTS sku_sidebar_entries;"
  end
end
