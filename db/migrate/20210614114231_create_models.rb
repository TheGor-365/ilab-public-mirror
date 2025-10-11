class CreateModels < ActiveRecord::Migration[6.1]
  def change
    create_table :models do |t|
      t.integer :generation_id
      t.integer :phone_id
      t.string  :title
      t.string  :avatar
      t.string  :images, array: true, default: []
      t.string  :videos, array: true, default: []

      t.timestamps
    end
  end
end
