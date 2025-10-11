class OrderItemsController < ApplicationController
  before_action :set_order
  before_action :set_delivery_price
  before_action :set_item, only: [:update, :destroy]

  def create
    # ожидаем params[:order_item][:product_id]
    product_id = order_params[:product_id]
    qty        = (order_params[:quantity] || 1).to_i
    qty = 1 if qty < 1

    @order.save if @order.new_record?

    @order_item = @order.order_items.find_by(product_id: product_id)
    if @order_item
      @order_item.update(quantity: @order_item.quantity + qty)
    else
      @order_item = @order.order_items.build(order_params.merge(quantity: qty))
      @order_item.save
    end

    session[:order_id] = @order.id

    @order_items   = @order.order_items.includes(:product)
    @items_count   = @order_items.sum(:quantity)
    @subtotal      = @order.subtotal
    @amount        = @subtotal + @delivery_price

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: 'Товар добавлен в корзину.' }
    end
  end

  def update
    qty = (order_params[:quantity] || 1).to_i
    if qty <= 0
      @order_item.destroy
    else
      @order_item.update(quantity: qty)
    end

    @order_items   = @order.order_items.includes(:product)
    @items_count   = @order_items.sum(:quantity)
    @subtotal      = @order.subtotal
    @amount        = @subtotal + @delivery_price

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: 'Корзина обновлена.' }
    end
  end

  def update_all
    # Хук под массовое обновление при необходимости
    redirect_to cart_path
  end

  def destroy
    @order_item.destroy

    @order_items   = @order.order_items.includes(:product)
    @items_count   = @order_items.sum(:quantity)
    @subtotal      = @order.subtotal
    @amount        = @subtotal + @delivery_price

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: 'Позиция удалена.' }
    end
  end

  def destroy_all
    @order.order_items.delete_all

    @order_items   = []
    @items_count   = 0
    @subtotal      = 0
    @amount        = @delivery_price

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: 'Корзина очищена.' }
    end
  end

  private

  def set_item
    @order_item = @order.order_items.find(params[:id])
  end

  def order_params
    params.require(:order_item).permit(:product_id, :quantity)
  end

  def set_order
    @order = current_order
  end

  def set_delivery_price
    @delivery_price = 30
  end
end
