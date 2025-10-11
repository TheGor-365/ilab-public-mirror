# frozen_string_literal: true
class AddPhoneAndGenerationToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :phone, foreign_key: true unless column_exists?(:products, :phone_id)
    add_reference :products, :generation, foreign_key: true unless column_exists?(:products, :generation_id)
  end
end
