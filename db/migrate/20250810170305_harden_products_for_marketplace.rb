# frozen_string_literal: true
class HardenProductsForMarketplace < ActiveRecord::Migration[7.0]
  def change
    change_table :products, bulk: true do |t|
      t.integer :condition, null: false, default: 1    # 0:new,1:used,2:for_parts,3:refurbished
      t.integer :state,     null: false, default: 0    # 0:draft,1:active,2:paused,3:sold,4:archived
      t.integer :stock,     null: false, default: 1
      t.string  :currency,  null: false, default: 'RUB'
      t.jsonb   :location_json, null: false, default: {}
      t.boolean :featured, null: false, default: false
      t.integer :violations_count, null: false, default: 0
    end
    add_index :products, :state
    add_index :products, :condition
    add_index :products, :price
  end
end
