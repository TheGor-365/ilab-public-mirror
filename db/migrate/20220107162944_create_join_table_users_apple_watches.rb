class CreateJoinTableUsersAppleWatches < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :apple_watches do |t|
      t.index [:user_id, :apple_watch_id]
      t.index [:apple_watch_id, :user_id]
    end
  end
end
