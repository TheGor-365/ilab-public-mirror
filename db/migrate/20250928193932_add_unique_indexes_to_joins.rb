class AddUniqueIndexesToJoins < ActiveRecord::Migration[7.1]
  def up
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_phones_repairs_phone_id_repair_id ON phones_repairs (phone_id, repair_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_defects_phones_defect_id_phone_id ON defects_phones (defect_id, phone_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_mods_repairs_mod_id_repair_id ON mods_repairs (mod_id, repair_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_defects_mods_defect_id_mod_id ON defects_mods (defect_id, mod_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_defects_repairs_defect_id_repair_id ON defects_repairs (defect_id, repair_id);"

    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_product_repairs_product_id_repair_id ON product_repairs (product_id, repair_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_product_defects_product_id_defect_id ON product_defects (product_id, defect_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_product_mods_product_id_mod_id ON product_mods (product_id, mod_id);"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS ux_product_spare_parts_product_id_spare_part_id ON product_spare_parts (product_id, spare_part_id);"
  end

  def down
    execute "DROP INDEX IF EXISTS ux_phones_repairs_phone_id_repair_id;"
    execute "DROP INDEX IF EXISTS ux_defects_phones_defect_id_phone_id;"
    execute "DROP INDEX IF EXISTS ux_mods_repairs_mod_id_repair_id;"
    execute "DROP INDEX IF EXISTS ux_defects_mods_defect_id_mod_id;"
    execute "DROP INDEX IF EXISTS ux_defects_repairs_defect_id_repair_id;"

    execute "DROP INDEX IF EXISTS ux_product_repairs_product_id_repair_id;"
    execute "DROP INDEX IF EXISTS ux_product_defects_product_id_defect_id;"
    execute "DROP INDEX IF EXISTS ux_product_mods_product_id_mod_id;"
    execute "DROP INDEX IF EXISTS ux_product_spare_parts_product_id_spare_part_id;"
  end
end
