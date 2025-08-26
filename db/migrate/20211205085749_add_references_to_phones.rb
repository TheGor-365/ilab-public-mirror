class AddReferencesToPhones < ActiveRecord::Migration[6.1]
  def change
    #add_reference :phones, :owned_gadget, null: true,  foreign_key: true
    add_reference :phones, :generation,   null: false, foreign_key: true
  end
end
