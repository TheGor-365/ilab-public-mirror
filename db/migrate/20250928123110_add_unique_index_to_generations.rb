class AddUniqueIndexToGenerations < ActiveRecord::Migration[7.1]
  def change
    add_index :generations, [:family, :title], unique: true, name: "idx_generations_family_title"
  end
end
