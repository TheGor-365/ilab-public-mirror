# frozen_string_literal: true
class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :provider, null: false, default: 0 # stripe,yookassa,cloudpayments,paypal
      t.string  :provider_payment_id
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string  :currency, null: false, default: 'RUB'
      t.integer :status, null: false, default: 0   # created,authorized,captured,canceled,refunded,failed
      t.string  :error_code
      t.jsonb   :payload, null: false, default: {}
      t.datetime :paid_at
      t.timestamps
    end
    add_index :payments, %i[provider provider_payment_id], unique: true
    add_index :payments, :status
  end
end
