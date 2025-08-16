# frozen_string_literal: true
class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0   # 0:shipping,1:billing
      t.string  :country_code, null: false
      t.string  :city, null: false
      t.string  :line1, null: false
      t.string  :line2
      t.string  :postal_code
      t.string  :phone
      t.string  :contact_name
      t.boolean :is_default, null: false, default: false
      t.timestamps
    end
  end
end
