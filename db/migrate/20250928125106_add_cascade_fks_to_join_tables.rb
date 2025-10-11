class AddCascadeFksToJoinTables < ActiveRecord::Migration[7.1]
  def change
    # helper для безопасного пересоздания FK
    def recreate_fk(from, col, to, name)
      reversible do |dir|
        dir.up do
          execute "ALTER TABLE #{from} DROP CONSTRAINT IF EXISTS #{name}"
          execute <<~SQL
            ALTER TABLE #{from}
            ADD CONSTRAINT #{name}
            FOREIGN KEY (#{col})
            REFERENCES #{to}(id)
            ON DELETE CASCADE
          SQL
        end
        dir.down do
          execute "ALTER TABLE #{from} DROP CONSTRAINT IF EXISTS #{name}"
          execute <<~SQL
            ALTER TABLE #{from}
            ADD CONSTRAINT #{name}
            FOREIGN KEY (#{col})
            REFERENCES #{to}(id)
          SQL
        end
      end
    end

    # defects_repairs(repair_id, defect_id)
    recreate_fk "defects_repairs", "repair_id", "repairs", "fk_dr_repair"
    recreate_fk "defects_repairs", "defect_id", "defects", "fk_dr_defect"

    # mods_repairs(repair_id, mod_id)
    recreate_fk "mods_repairs", "repair_id", "repairs", "fk_mr_repair"
    recreate_fk "mods_repairs", "mod_id",    "mods",    "fk_mr_mod"

    # defects_mods(defect_id, mod_id)
    recreate_fk "defects_mods", "defect_id", "defects", "fk_dm_defect"
    recreate_fk "defects_mods", "mod_id",    "mods",    "fk_dm_mod"

    # phones_repairs(phone_id, repair_id)
    recreate_fk "phones_repairs", "phone_id",  "phones",  "fk_pr_phone"
    recreate_fk "phones_repairs", "repair_id", "repairs", "fk_pr_repair"

    # product_* (если есть)
    recreate_fk "product_repairs",     "product_id", "products", "fk_prdrep_product"     rescue nil
    recreate_fk "product_repairs",     "repair_id",  "repairs",  "fk_prdrep_repair"      rescue nil
    recreate_fk "product_defects",     "product_id", "products", "fk_prddef_product"     rescue nil
    recreate_fk "product_defects",     "defect_id",  "defects",  "fk_prddef_defect"      rescue nil
    recreate_fk "product_mods",        "product_id", "products", "fk_prdmod_product"     rescue nil
    recreate_fk "product_mods",        "mod_id",     "mods",     "fk_prdmod_mod"         rescue nil
    recreate_fk "product_spare_parts", "product_id", "products", "fk_prdsp_product"      rescue nil
    recreate_fk "product_spare_parts", "spare_part_id", "spare_parts", "fk_prdsp_spare"  rescue nil
  end
end
