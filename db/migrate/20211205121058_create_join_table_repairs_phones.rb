class CreateJoinTableRepairsPhones < ActiveRecord::Migration[6.1]
  def change
    create_join_table :repairs, :phones do |t|
      t.index [:repair_id, :phone_id]
      t.index [:phone_id, :repair_id]
    end
  end
end
