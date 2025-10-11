class CreateDefects < ActiveRecord::Migration[6.1]
  def change
    create_table :defects do |t|
      t.integer :generation_id
      t.integer :phone_id
      t.integer :repair_id
      t.integer :mod_id
      t.string  :title
      t.string  :description
      t.string  :avatar
      t.string  :modules, array: true, default: []
      t.string  :images,  array: true, default: []
      t.string  :videos,  array: true, default: []

      t.timestamps
    end
  end
end
