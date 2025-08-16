# frozen_string_literal: true
class ExtendOrders < ActiveRecord::Migration[7.0]
  def change
    change_table :orders, bulk: true do |t|
      t.references :user,   foreign_key: true
      t.references :seller, foreign_key: { to_table: :users }
      t.string  :number
      t.integer :state, null: false, default: 0 # pending..refunded
      t.decimal :delivery, precision: 12, scale: 2, null: false, default: 0
      t.decimal :fee,      precision: 12, scale: 2, null: false, default: 0
      t.string  :currency, null: false, default: 'RUB'
      t.integer :payment_method
      t.references :shipping_address, foreign_key: { to_table: :addresses }
      t.references :billing_address,  foreign_key: { to_table: :addresses }
      t.datetime :paid_at
      t.datetime :canceled_at
      t.string   :reason
      t.jsonb    :metadata, null: false, default: {}
    end
    add_index :orders, :number, unique: true
    add_index :orders, :state
    add_index :orders, :paid_at
  end
end
