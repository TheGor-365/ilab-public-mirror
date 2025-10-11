class AddInfoToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name,  :string
    add_column :users, :borned,     :datetime
    add_column :users, :birthday,   :datetime
    add_column :users, :images, :text, array: true, default: []
    add_column :users, :videos, :text, array: true, default: []
  end
end
