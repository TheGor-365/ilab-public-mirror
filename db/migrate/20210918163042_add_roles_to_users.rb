class AddRolesToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :admin,     :boolean, default: false
    add_column :users, :author,    :boolean, default: true
    add_column :users, :repairman, :boolean, default: false
    add_column :users, :teacher,   :boolean, default: false
    add_column :users, :student,   :boolean, default: false
    add_column :users, :customer,  :boolean, default: true
  end
end
