class CreateJoinTableUsersMakbooks < ActiveRecord::Migration[6.1]
  def change
    create_join_table :users, :makbooks do |t|
      t.index [:user_id, :makbook_id]
      t.index [:makbook_id, :user_id]
    end
  end
end
