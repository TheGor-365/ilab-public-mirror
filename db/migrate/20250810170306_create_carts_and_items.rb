# frozen_string_literal: true
class CreateCartsAndItems < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.references :user, foreign_key: true
      t.string  :session_id
      t.integer :items_count, null: false, default: 0
      t.decimal :total, precision: 12, scale: 2, null: false, default: 0
      t.string  :currency, null: false, default: 'RUB'
      t.timestamps
    end
    add_index :carts, :session_id, unique: true

    create_table :cart_items do |t|
      t.references :cart,    null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.decimal :unit_price, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total,      precision: 12, scale: 2, null: false, default: 0
      t.string  :currency, null: false, default: 'RUB'
      t.timestamps
    end
    add_index :cart_items, %i[cart_id product_id], unique: true
  end
end
