class ProductsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_product, only: %i[ show edit update destroy product_description ]

  def index
    @products = Product.all
  end

  def show
  end

  def edit; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    @product.category = Category.find(params[:product][:category_id])

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @product.category = Category.find(params[:product][:category_id])

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

    gen_id = @generation&.id
    @repairs     = gen_id ? Repair.where(generation_id: gen_id).includes(:user).limit(10) : Repair.none
    @defects     = gen_id ? Defect.where(generation_id: gen_id).limit(10) : Defect.none
    @spare_parts = gen_id ? SparePart.where(generation_id: gen_id).includes(:vendor).limit(10) : SparePart.none
    @mods        = gen_id ? Mod.where(generation_id: gen_id).limit(10) : Mod.none

    respond_to(&:turbo_stream)
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :category_id,
      :iphone_id,
      :model_id,
      :storage,
      :color,
      :price_cents,
      :name,
      :description,
      :price,
      :avatar,
      :is_best_offer,
      :images_cache,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
