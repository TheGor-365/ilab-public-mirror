class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string  :heading,  default: ''
      t.text    :overview, default: ''
      t.boolean :display,  default: true
      t.string  :avatar,   default: ''
      t.string  :images,   array: true, default: []
      t.string  :videos,   array: true, default: []

      t.timestamps
    end
  end
end
