class OrderItem < ApplicationRecord
  belongs_to :product
  belongs_to :order

  before_save :set_unit_price
  before_save :set_total

  def unit_price
    persisted? ? self[:unit_price] : product.price
  end

  def total
    unit_price.to_f * quantity.to_i
  end

  private

  def set_unit_price
    self[:unit_price] = product.price
  end

  def set_total
    # исправлено: total = unit_price * quantity (без повторного умножения)
    self[:total] = unit_price.to_f * quantity.to_i
  end
end
