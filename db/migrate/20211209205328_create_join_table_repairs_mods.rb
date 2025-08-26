class CreateJoinTableRepairsMods < ActiveRecord::Migration[6.1]
  def change
    create_join_table :repairs, :mods do |t|
      t.index [:repair_id, :mod_id]
      t.index [:mod_id, :repair_id]
    end
  end
end
