class CreateJoinTablePhonesDefects < ActiveRecord::Migration[6.1]
  def change
    create_join_table :phones, :defects do |t|
      t.index [:phone_id, :defect_id]
      t.index [:defect_id, :phone_id]
    end
  end
end
