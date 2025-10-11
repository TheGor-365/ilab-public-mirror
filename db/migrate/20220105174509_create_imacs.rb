class CreateImacs < ActiveRecord::Migration[6.1]
  def change
    create_table :imacs do |t|
      #t.references :user, null: true, foreign_key: true
      t.string     :title
      t.string     :diagonal
      t.string     :model
      t.string     :version
      t.string     :series
      t.datetime   :production_period
      t.string     :full_title
      t.text       :overview
      t.string     :avatar
      t.string     :images, array: true, default: []
      t.string     :videos, array: true, default: []

      t.timestamps
    end
  end
end
