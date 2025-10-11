class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :user,   null: false, foreign_key: true
      t.string     :title
      t.integer    :views,  default: 0
      t.string     :avatar, default: ''
      t.string     :images, array: true, default: []
      t.string     :videos, array: true, default: []

      t.timestamps
    end
  end
end
