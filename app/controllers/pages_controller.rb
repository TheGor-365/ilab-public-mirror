class PagesController < ApplicationController

  before_action :set_products
  before_action :set_order
  before_action :set_delivery_price

  def home
  end

  def terms
  end

  def contacts
  end

  def store
    @product = Product.first
    @repairs = Repair.all
    @defects = Defect.all
    @spare_parts = SparePart.all
    @mods = Mod.all
    @products = Product.all
    @categories = Category.all

    @products_by_category = Product
      .includes(:generation) # чтобы не ловить N+1 на названии
      .group_by(&:store_group)

    # выбрасываем пустой ключ на всякий случай
    @products_by_category.delete(nil)

    @order_item = current_order.order_items.new
    @order_items = current_order.order_items
  end



  private

  def set_products
    @products = Product.all
  end

  def set_order
    @order = current_order
  end

  def set_delivery_price
    @delivery_price = 30
  end
end
