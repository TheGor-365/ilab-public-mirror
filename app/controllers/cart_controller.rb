class CartController < ApplicationController
  before_action :set_delivery_price
  before_action :set_order
  before_action :set_order_items

  def show
    @products = Product.all

    # Группировка по типам для навигации (эвристика по названию категории)
    @grouped_items = {
      device:  [],
      part:    [],
      service: []
    }

    @order_items.each do |item|
      type = guess_type(item.product)
      @grouped_items[type] << item
    end

    @items_count = @order_items.sum(:quantity)
    @subtotal    = @order.subtotal
    @amount      = @subtotal + @delivery_price
  end

  private

  def guess_type(product)
    title = (product.try(:category)&.try(:title) || product.try(:category)&.try(:name) || "").to_s.downcase

    return :service if title.match?(/ремонт|repair|услуг|service|тюнинг|upgrade|обуч/i)
    return :part    if title.match?(/part|запчаст|аксесс|accessor|module|модул/i)

    :device
  end

  def set_order
    @order = current_order
  end

  def set_order_items
    @order_items = current_order.order_items.includes(:product)
  end

  def set_delivery_price
    @delivery_price = 30
  end
end
