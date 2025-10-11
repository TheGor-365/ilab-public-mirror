class CreateJoinTableDefectsRepairs < ActiveRecord::Migration[6.1]
  def change
    create_join_table :defects, :repairs do |t|
      t.index [:defect_id, :repair_id]
      t.index [:repair_id, :defect_id]
    end
  end
end
