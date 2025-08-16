class CreateJoinTableUsersAirpods < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :airpods do |t|
      t.index [:user_id, :airpod_id]
      t.index [:airpod_id, :user_id]
    end
  end
end
