class CreateJoinTableUsersImacs < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :imacs do |t|
      t.index [:user_id, :imac_id]
      t.index [:imac_id, :user_id]
    end
  end
end
