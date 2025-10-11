class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.references :user
      t.string     :name
      t.string     :avatar, default: ''
      t.string     :images, array: true, default: []
      t.string     :videos, array: true, default: []

      t.timestamps
    end
  end
end
