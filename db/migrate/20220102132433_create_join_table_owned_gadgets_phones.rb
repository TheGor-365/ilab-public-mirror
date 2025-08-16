class CreateJoinTableOwnedGadgetsPhones < ActiveRecord::Migration[6.1]
  def change
    create_join_table :owned_gadgets, :phones do |t|
      t.index [:owned_gadget_id, :phone_id]
      t.index [:phone_id, :owned_gadget_id]
    end
  end
end
