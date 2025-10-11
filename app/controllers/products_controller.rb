class ProductsController < ApplicationController
  helper ProductsHelper

  before_action :authenticate_user!
  before_action :set_product, only: %i[ show edit update destroy product_description ]

  def index
    @products = Product.all
  end

  def show
    per = 10
    @sidebar_rows = {
      repairs:     @product.repairs.limit(per).map     { |r| [:repair,     r.id, r.try(:title) || "Repair ##{r.id}"] },
      defects:     @product.defects.limit(per).map     { |d| [:defect,     d.id, d.try(:title) || "Defect ##{d.id}"] },
      mods:        @product.mods.limit(per).map        { |m| [:mod,        m.id, m.try(:title) || m.try(:name) || "Mod ##{m.id}"] },
      spare_parts: @product.spare_parts.limit(per).map { |s| [:spare_part, s.id, s.try(:name) || "Spare Part ##{s.id}"] },
    }

    @sidebar_count = {
      repairs:     @product.repairs.count,
      defects:     @product.defects.count,
      mods:        @product.mods.count,
      spare_parts: @product.spare_parts.count,
    }

    respond_to do |format|
      format.html
      format.turbo_stream { render :show, formats: [:html] }
    end
  end

  def edit; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.seller = current_user

    # связываем чекбоксы/селекты (без пустых значений)
    @product.defect_ids     = Array(params.dig(:product, :defect_ids)).reject(&:blank?)
    @product.repair_ids     = Array(params.dig(:product, :repair_ids)).reject(&:blank?)
    @product.mod_ids        = Array(params.dig(:product, :mod_ids)).reject(&:blank?)
    @product.spare_part_ids = Array(params.dig(:product, :spare_part_ids)).reject(&:blank?)

    # категория при наличии
    if params.dig(:product, :category_id).present?
      @product.category = Category.find_by(id: params[:product][:category_id])
    end

    if @product.save
      respond_to do |format|
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.turbo_stream { redirect_to @product }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::RecordNotUnique
    # на случай гонки при сохранении: показываем нормальную ошибку формы
    @product.errors.add(:sku_id, "у вас уже есть опубликованное объявление с этим SKU")
    respond_to do |format|
      format.html { render :new, status: :unprocessable_entity }
      format.turbo_stream { render :new, status: :unprocessable_entity }
    end
  end

  def update
    @product.category = Category.find_by(id: params.dig(:product, :category_id)) if params.dig(:product, :category_id).present?

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
    end
  end

  # === Turbo details
  def product_description
    @product = Product.find(params[:id])

    if @product.phone.nil? || @product.generation.nil?
      ctx = Resolvers::ProductMatcher.call(@product)
      @model, @phone, @generation = ctx.model, ctx.phone, ctx.generation
    else
      @phone, @generation = @product.phone, @product.generation
      @model = @generation&.respond_to?(:model) ? @generation.model : @phone&.try(:model)
    end

    @category = @product.category
    gen_id    = @generation&.id

    @catalog_repairs     = gen_id ? Repair.where(generation_id: gen_id).limit(30)    : Repair.none
    @catalog_defects     = gen_id ? Defect.where(generation_id: gen_id).limit(30)    : Defect.none
    @catalog_mods        = gen_id ? Mod.where(generation_id: gen_id).limit(30)       : Mod.none
    @catalog_spare_parts = gen_id ? SparePart.where(generation_id: gen_id).limit(30) : SparePart.none

    @attached_repairs     = @product.repairs.limit(12)
    @attached_defects     = @product.defects.limit(12)
    @attached_mods        = @product.mods.limit(12)
    @attached_spare_parts = @product.spare_parts.limit(12)

    @attached_counts = {
      repairs:      @product.repairs.count,
      defects:      @product.defects.count,
      mods:         @product.mods.count,
      spare_parts:  @product.spare_parts.count
    }

    expires_now
    response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
    response.headers["Pragma"]        = "no-cache"

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @product }
    end
  end

  # === JSON: поиск моделей
  def catalog_phones
    family = params[:family].to_s.presence
    q      = params[:q].to_s.strip
    all    = ActiveModel::Type::Boolean.new.cast(params[:all])

    scope = Phone.joins(:generation)
    scope = scope.where(generations: { family: family }) if family.present?

    if q.present?
      cols  = Phone.column_names
      args  = { q: "%#{q.downcase}%" }
      conds = []
      conds << "LOWER(phones.title) LIKE :q"       if cols.include?("title")
      conds << "LOWER(phones.model_title) LIKE :q" if cols.include?("model_title")
      conds << "LOWER(phones.name) LIKE :q"        if cols.include?("name")
      scope = scope.where(conds.join(" OR "), args) if conds.any?
    end

    scope = scope.order("phones.id DESC")
    scope = scope.limit(500) unless all

    render json: {
      phones: scope.map { |p| { id: p.id, generation_id: p.generation_id, label: phone_label(p) } }
    }
  end

  # === JSON: дерево опций для SKU + каталожные чекбоксы
  def catalog_tree
    gen_id   = params[:generation_id].presence
    phone_id = params[:phone_id].presence
    storage  = params[:storage].presence
    color    = params[:color].presence

    if gen_id.blank? && phone_id.present?
      gen_id = Phone.where(id: phone_id).limit(1).pick(:generation_id)
    end

    phones = gen_id.present? ? Phone.where(generation_id: gen_id).order(:id) : Phone.none

    storages = begin
      base = Sku.where(generation_id: gen_id)
      s = phone_id.present? ? base.where(phone_id: phone_id).distinct.order(:storage).pluck(:storage).compact : []
      s = base.distinct.order(:storage).pluck(:storage).compact if s.empty?
      s
    end

    colors = begin
      base = Sku.where(generation_id: gen_id)
      c = phone_id.present? ? base.where(phone_id: phone_id).distinct.order(:color).pluck(:color).compact : []
      c = base.distinct.order(:color).pluck(:color).compact if c.empty?
      c
    end

    sku_id = nil
    if gen_id.present? && storage.present? && color.present?
      q = Sku.where(generation_id: gen_id, storage: storage, color: color)
      sku_id = q.where(phone_id: phone_id).limit(1).pick(:id) if phone_id.present?
      sku_id ||= q.limit(1).pick(:id)
    end

    generation_label = Generation.where(id: gen_id).limit(1).pick(:title) if gen_id.present?
    phone_label_val  = phone_id.present? ? phone_label(Phone.find_by(id: phone_id)) : nil

    defects = begin
      rel    = Defect.left_outer_joins(:phones)
      conds  = []
      binds  = {}
      if gen_id.present?
        conds << "defects.generation_id = :gid"; binds[:gid] = gen_id
      end
      if phone_id.present?
        conds << "phones.id = :pid"; binds[:pid] = phone_id
      end
      rel = conds.empty? ? Defect.none : rel.where(conds.join(" OR "), binds)
      rel.distinct.order(:id).limit(200)
    end

    repairs = begin
      rel    = Repair.left_outer_joins(:phones)
      conds  = []
      binds  = {}
      if gen_id.present?
        conds << "repairs.generation_id = :gid"; binds[:gid] = gen_id
      end
      if phone_id.present?
        conds << "phones.id = :pid"; binds[:pid] = phone_id
      end
      rel = conds.empty? ? Repair.none : rel.where(conds.join(" OR "), binds)
      rel.distinct.order(:id).limit(200)
    end

    mods = begin
      if gen_id.blank? && phone_id.blank?
        Mod.none
      else
        rel = Mod.all
        conds, binds = [], {}
        if gen_id.present?
          conds << "mods.generation_id = :gid"; binds[:gid] = gen_id
        end
        if phone_id.present?
          conds << "mods.phone_id = :pid"; binds[:pid] = phone_id
        end
        rel.where(conds.join(" OR "), binds).distinct.order(:id).limit(200)
      end
    end

    spare_parts = begin
      if gen_id.blank? && phone_id.blank?
        SparePart.none
      else
        rel = SparePart.joins(:mod)
        conds, binds = [], {}
        if gen_id.present?
          conds << "mods.generation_id = :gid"; binds[:gid] = gen_id
        end
        if phone_id.present?
          conds << "mods.phone_id = :pid"; binds[:pid] = phone_id
        end
        rel.where(conds.join(" OR "), binds).distinct.order(:id).limit(200)
      end
    end

    render json: {
      phones: phones.map { |p| { id: p.id, label: phone_label(p) } },

      storages: storages.map { |s| { id: s, label: s } },
      colors:   colors.map   { |c| { id: c, label: c } },

      sku_id: sku_id,

      generation_label: generation_label,
      phone_label:      phone_label_val,
      storage_label:    storage,
      color_label:      color,

      defects: defects.map     { |d| { id: d.id, label: (d.try(:title).presence || "Defect ##{d.id}") } },
      repairs: repairs.map     { |r| { id: r.id, label: (r.try(:title).presence || "Repair ##{r.id}") } },
      mods:    mods.map        { |m| { id: m.id, label: (m.try(:title).presence || m.try(:name).presence || "Mod ##{m.id}") } },
      spare_parts: spare_parts.map { |s| { id: s.id, label: (s.try(:name).presence || s.try(:title).presence || "Spare Part ##{s.id}") } }
    }
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :category_id,
      :generation_id,
      :phone_id,
      :model_id,
      :sku_id,
      :storage,
      :color,
      :price_cents,
      :price,
      :currency,
      :name,
      :description,
      :condition,
      :state,
      :avatar,
      :is_best_offer,
      :images_cache,
      :avatar_cache,
      { images: [] },
      { videos: [] },
      { defect_ids: [] },
      { repair_ids: [] },
      { spare_part_ids: [] },
      { mod_ids: [] }
    )
  end

  def phone_label(p)
    return "" unless p
    p.try(:title).presence ||
      p.try(:model_title).presence ||
      p.try(:name).presence ||
      "Phone ##{p.id}"
  end
end
