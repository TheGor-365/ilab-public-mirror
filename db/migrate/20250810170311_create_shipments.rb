# frozen_string_literal: true
class CreateShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.string  :tracking_number
      t.string  :carrier
      t.integer :status, null: false, default: 0  # preparing..delivered/problem
      t.jsonb   :payload, null: false, default: {}
      t.datetime :shipped_at
      t.datetime :delivered_at
      t.timestamps
    end
    add_index :shipments, :tracking_number
  end
end
