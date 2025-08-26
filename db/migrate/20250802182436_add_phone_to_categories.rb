class AddPhoneToCategories < ActiveRecord::Migration[7.1]
  def change
    add_reference :categories, :phone, foreign_key: true, null: true
  end
end
