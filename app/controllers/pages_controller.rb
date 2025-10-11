class PagesController < ApplicationController
  before_action :set_products
  before_action :set_order
  before_action :set_delivery_price

  HIDDEN_FAMILIES = [].freeze

  def home
    @stats = {
      products:    safe_count(Product),
      families:    safe_count_families,
      repairs:     safe_count(Repair),
      spare_parts: safe_count(SparePart),
      mods:        safe_count(Mod),
      avg_price:   active_avg_price # показываем как «Средняя выгода» на вьюхе
    }

    # Безопасная сортировка по количеству
    @top_families = Generation
      .group(:family)
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(8)
      .count
  end

  def terms; end
  def contacts; end

  # Витрина магазина
  def store
    # 1) Фильтр по семейству
    @family   = params[:family].presence
    @families = Generation.distinct.order(:family).pluck(:family).compact.reject { |f| HIDDEN_FAMILIES.include?(f) }

    # 2) Базовый набор
    products = Product
                 .includes(:generation, :model, :phone, :category)
                 .where("price IS NOT NULL AND price > 0")

    # 2.1) статус "active" (enum или текст)
    if Product.respond_to?(:states) && Product.states[:active]
      products = products.where(state: Product.states[:active])
    else
      col = Product.columns_hash["state"]
      active_val = col&.type == :integer ? 0 : "active"
      products = products.where(state: active_val) if col
    end

    # 3) Фильтр по семейству — только при наличии параметра
    if @family.present?
      products = products.joins(:generation).where(generations: { family: @family })
    end

    # 4) Группировка: сначала по поколению (если есть), иначе по категории
    grouped = products.to_a.group_by { |p| p.generation || p.category }

    # 5) Сортировка внутри групп и ограничение 10 шт
    @products_by_category = grouped.transform_values do |arr|
      arr.sort_by { |p| (p.try(:display_name).presence || p.name.to_s) }.first(10)
    end

    # 6) Для правой карточки/навигации
    @total_products = products.size
    @by_section = @products_by_category.each_with_object({}) do |(key, list), h|
      title =
        if key.respond_to?(:heading) && key.heading.present?
          key.heading
        elsif key.respond_to?(:title)
          key.title.to_s
        else
          "Без категории"
        end
      h[title] = list
    end

    # 7) Для формы корзины
    @order_item  = @order.order_items.build
    @order_items = @order.order_items
  end

  private

  def safe_count(klass)
    klass.respond_to?(:count) ? klass.count : 0
  rescue
    0
  end

  def safe_count_families
    Generation.distinct.count(:family)
  rescue
    0
  end

  def state_active_value
    if Product.respond_to?(:states) && (Product.states.key?("active") || Product.states.key?(:active))
      Product.states["active"] || Product.states[:active]
    else
      col = Product.columns_hash["state"]
      col&.type == :integer ? 0 : "active"
    end
  end

  def active_avg_price
    prices = Product.where(state: state_active_value).where("price > 0").limit(5000).pluck(:price)
    return 0 if prices.blank?
    (prices.sum.to_f / prices.size).round(0)
  rescue
    0
  end

  def set_products
    @products = Product.all

    scope = Product.where("price IS NOT NULL AND price > 0").order(id: :desc)
    scope = scope.where(state: state_active_value) if Product.column_names.include?("state")
    @latest_products = scope.limit(6)
  rescue
    @latest_products = []
  end

  def set_order
    @order = current_order
  end

  def set_delivery_price
    @delivery_price = 30
  end
end
