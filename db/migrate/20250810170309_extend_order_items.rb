# frozen_string_literal: true
class ExtendOrderItems < ActiveRecord::Migration[7.0]
  def change
    change_table :order_items, bulk: true do |t|
      t.string :currency, null: false, default: 'RUB'
      t.string :title_snapshot
      t.jsonb  :meta, null: false, default: {}
    end
  end
end
