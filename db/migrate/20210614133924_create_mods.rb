class CreateMods < ActiveRecord::Migration[6.1]
  def change
    create_table :mods do |t|
      t.integer :generation_id
      t.integer :phone_id
      t.integer :model_id
      t.integer :defect_id
      t.integer :repair_id
      t.string  :name
      t.string  :avatar
      t.string  :manufacturers, array: true, default: []
      t.string  :images,        array: true, default: []
      t.string  :videos,        array: true, default: []

      t.timestamps
    end
  end
end
