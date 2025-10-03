class PagesController < ApplicationController
  before_action :set_products
  before_action :set_order
  before_action :set_delivery_price

  HIDDEN_FAMILIES = [].freeze

  def home; end
  def terms; end
  def contacts; end

  # Витрина магазина
  def store
    # 1) Фильтр по семейству
    @family   = params[:family].presence
    @families = Generation.distinct.order(:family).pluck(:family).compact.reject { |f| HIDDEN_FAMILIES.include?(f) }

    # 2) Базовый набор без прежних жёстких фильтров storage/color/generation
    products = Product
                 .includes(:generation, :model, :phone, :category)
                 .where("price IS NOT NULL AND price > 0")

    # 2.1) статус "active" (integer enum)
    if Product.respond_to?(:states) && Product.states[:active]
      products = products.where(state: Product.states[:active])
    end

    # 3) Фильтр по семейству — только при наличии параметра
    if @family.present?
      products = products.joins(:generation).where(generations: { family: @family })
    end

    # 4) Группировка: сначала по поколению (если есть), иначе по категории
    grouped = products.group_by { |p| p.generation || p.category }

    # 5) Сортировка внутри групп и ограничение 10 шт
    @products_by_category = grouped.transform_values do |arr|
      arr.sort_by { |p| p.try(:display_name).presence || p.name.to_s }.first(10)
    end

    # 6) Для правой карточки/навигации
    @total_products = products.size
    @by_section = @products_by_category.transform_keys do |key|
      if key.respond_to?(:heading) && key.heading.present?
        key.heading
      elsif key.respond_to?(:title)
        key.title.to_s
      else
        "Без категории"
      end
    end

    # 7) Для формы корзины
    @order_item  = @order.order_items.build
    @order_items = @order.order_items
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
