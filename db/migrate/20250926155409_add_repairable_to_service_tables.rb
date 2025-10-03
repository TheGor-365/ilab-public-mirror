class AddRepairableToServiceTables < ActiveRecord::Migration[7.1]
  def change
    add_reference :repairs,      :repairable, polymorphic: true, index: true
    add_reference :defects,      :repairable, polymorphic: true, index: true
    add_reference :mods,         :repairable, polymorphic: true, index: true
    add_reference :spare_parts,  :repairable, polymorphic: true, index: true
    
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE repairs      SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;
          UPDATE defects      SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;
          UPDATE mods         SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;
          UPDATE spare_parts  SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;
        SQL
      end
    end
  end
end
