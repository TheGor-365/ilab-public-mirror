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
    base = Product
             .includes(:generation, :model, :phone)
             .where.not(generation_id: nil)
             .where.not(storage: [nil, ""])
             .where.not(color:   [nil, ""])
             .where("price > 0")

    @product = base
    # @product = Product.first
    @categories = Category.all
    @repairs = Repair.all
    @defects = Defect.all
    @spare_parts = SparePart.all
    @mods = Mod.all
    @products = Product.all
    

    @products_by_category = base.group_by(&:store_group)
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
