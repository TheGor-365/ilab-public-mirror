class PolymorphizeRepairEntities < ActiveRecord::Migration[7.1]
  TABLES = %i[repairs defects mods spare_parts].freeze

  def up
    TABLES.each do |t|
      # Если предыдущая миграция не была применена по какой-то причине — добавим repairable_* тут идемпотентно
      unless column_exists?(t, :repairable_type) && column_exists?(t, :repairable_id)
        add_reference t, :repairable, polymorphic: true, index: false
      end

      # Композитный индекс (если его нет или создавался по другому имени)
      unless index_exists?(t, [:repairable_type, :repairable_id], name: "idx_#{t}_repairable_poly")
        add_index t, [:repairable_type, :repairable_id], name: "idx_#{t}_repairable_poly"
      end
    end

    say_with_time "Backfilling repairable_* from legacy phone_id…" do
      execute "UPDATE repairs      SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;"
      execute "UPDATE defects      SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;"
      execute "UPDATE mods         SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;"
      execute "UPDATE spare_parts  SET repairable_type = 'Phone', repairable_id = phone_id WHERE phone_id IS NOT NULL AND repairable_id IS NULL;"
    end
  end

  def down
    TABLES.each do |t|
      remove_index t, name: "idx_#{t}_repairable_poly" if index_exists?(t, name: "idx_#{t}_repairable_poly")
      if column_exists?(t, :repairable_type) && column_exists?(t, :repairable_id)
        remove_reference t, :repairable, polymorphic: true
      end
    end
  end
end
