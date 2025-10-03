class CreateRepairs < ActiveRecord::Migration[6.1]
  def change
    create_table :repairs do |t|
      t.integer :generation_id
      t.integer :phone_id
      t.integer :defect_id
      t.integer :mod_id
      t.string  :title
      t.string  :description
      t.string  :overview
      t.string  :avatar
      t.string  :spare_parts, array: true, default: []
      t.string  :images,      array: true, default: []
      t.string  :videos,      array: true, default: []
      t.string  :price

      t.timestamps
    end
  end
end
