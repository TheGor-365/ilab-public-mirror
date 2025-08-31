class CartController < ApplicationController

  before_action :set_delivery_price
  before_action :set_order_items
  before_action :set_order

  def show
    @products = Product.all
  end

  private

  def set_order
    @order = current_order
  end

  def set_order_items
    @order_items = current_order.order_items
  end

  def set_delivery_price
    @delivery_price = 30
  end

end
