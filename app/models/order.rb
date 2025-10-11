class Order < ApplicationRecord
  before_save :set_subtotal

  has_many :order_items

  def subtotal
    order_items.to_a.sum { |oi| oi.valid? ? oi.unit_price.to_f * oi.quantity.to_i : 0 }
  end

  private

  def set_subtotal
    self[:subtotal] = subtotal
  end
end
