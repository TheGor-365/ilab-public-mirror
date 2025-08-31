class OrderItemsController < ApplicationController

  before_action :set_order
  before_action :set_delivery_price

  def create
    @order_items = OrderItem.all
    @order_item = @order.order_items.find(params[:id]) if @order_item.present?

    if @order_items.include?(@order_item)

      @order_item = @order_items.find_by(product_id: OrderItem.find(params[:id]).product.id)
      @order_item.quantity = OrderItem.find(params[:id]).quantity
      @order_item.quantity += 1
    else
      @order_item = @order.order_items.new(order_params)
      @order.save
    end

    redirect_to cart_path
    session[ :order_id ] = @order.id
  end

  def update
    @order_item = @order.order_items.find(params[:id])
    @order_item.update(order_params)

    redirect_to cart_path
    @order_items = current_order.order_items
  end

  def update_all

    redirect_to cart_path
  end

  def destroy
    @order_item = @order.order_items.find(params[:id])
    @order_item.destroy

    redirect_to cart_path
  end

  def destroy_all
    OrderItem.all.delete_all

    redirect_to cart_path
  end

  private

  def order_params
    params.require(:order_item).permit(
      :product_id,
      :quantity
    )
  end

  def set_order
    @order = current_order
  end

  def set_delivery_price
    @delivery_price = 30
  end

end
