class CreateJoinTableUsersIpads < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :ipads do |t|
      t.index [:user_id, :ipad_id]
      t.index [:ipad_id, :user_id]
    end
  end
end
