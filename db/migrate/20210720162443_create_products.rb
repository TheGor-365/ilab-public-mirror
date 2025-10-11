class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string  :name,                default: ''
      t.text    :description,         default: ''
      t.decimal :price,               default: 0.0
      t.boolean :is_best_offer,       default: false
      t.string  :avatar,              default: ''
      t.string  :images, array: true, default: []
      t.string  :videos, array: true, default: []

      t.timestamps
    end
  end
end
