class CreateCources < ActiveRecord::Migration[6.1]
  def change
    create_table :cources do |t|
      t.references :university, null: false, foreign_key: true
      t.references :category,   null: false, foreign_key: true
      t.references :generation, null: false, foreign_key: true
      t.references :model,      null: false, foreign_key: true

      t.string     :author
      t.string     :name
      t.text       :description
      t.decimal    :price
      t.string     :chapters, array: true, default: []
      t.string     :avatar,   default: ''
      t.string     :images,   array: true, default: []
      t.string     :videos,   array: true, default: []

      t.timestamps
    end
  end
end
