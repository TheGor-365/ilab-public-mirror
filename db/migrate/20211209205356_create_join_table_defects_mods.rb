class CreateJoinTableDefectsMods < ActiveRecord::Migration[6.1]
  def change
    create_join_table :defects, :mods do |t|
      t.index [:defect_id, :mod_id]
      t.index [:mod_id, :defect_id]
    end
  end
end
