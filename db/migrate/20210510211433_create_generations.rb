class CreateGenerations < ActiveRecord::Migration[6.1]
  def change
    create_table :generations do |t|
      t.string :title
      t.string :production_period
      t.string :features
      t.string :vulnerability
      t.string :avatar
      t.string :images, array: true, default: []
      t.string :videos, array: true, default: []

      t.timestamps
    end
  end
end
