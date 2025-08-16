# frozen_string_literal: true
class CreateFinanceModule < ActiveRecord::Migration[7.0]
  def change
    create_table :subscription_plans do |t|
      t.string  :name, null: false
      t.string  :slug, null: false
      t.integer :price_cents, null: false, default: 0
      t.integer :interval, null: false, default: 0 # month/year
      t.jsonb   :features, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :subscription_plans, :slug, unique: true
    add_index :subscription_plans, :active

    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, null: false, foreign_key: true
      t.integer :state, null: false, default: 0 # active,past_due,canceled
      t.datetime :current_period_end, null: false
      t.timestamps
    end
    add_index :subscriptions, :state

    create_table :commissions do |t|
      t.string  :name, null: false
      t.decimal :percent, precision: 6, scale: 3, null: false, default: 0
      t.integer :applies_to, null: false, default: 0 # order,subscription,boost
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :commissions, :active

    create_table :payouts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.string  :currency, null: false, default: 'RUB'
      t.integer :state, null: false, default: 0 # pending,paid,failed
      t.string  :provider
      t.jsonb   :payload, null: false, default: {}
      t.timestamps
    end
    add_index :payouts, :state
  end
end
