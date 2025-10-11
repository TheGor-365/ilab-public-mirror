class SparePartsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_spare_part, only: %i[ show edit update destroy ]

  def index
    scope = SparePart.all
    scope = scope.where(generation_id: params[:generation_id]) if params[:generation_id].present?
    scope = scope.where(phone_id:      params[:phone_id])      if params[:phone_id].present?

    if params[:model_id].present?
      scope = scope.joins(:mod).where(mods: { model_id: params[:model_id] })
    end

    if params[:product_id].present?
      scope = scope.joins(:products).where(products: { id: params[:product_id] })
    end

    @spare_parts = scope.distinct.order(:id).page(params[:page]).per(24) rescue scope.limit(100)
  end

  def show; end

  def edit; end

  def new
    @spare_part = SparePart.new
  end

  def create
    @spare_part = SparePart.new(spare_part_params)

    respond_to do |format|
      if @spare_part.save
        format.html { redirect_to @spare_part, notice: "Spare part was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @spare_part.update(spare_part_params)
        format.html { redirect_to @spare_part, notice: "Spare part was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @spare_part.destroy
    respond_to do |format|
      format.html { redirect_to spare_parts_url, notice: "Spare part was successfully destroyed." }
    end
  end

  private

  def set_spare_part
    @spare_part = SparePart.find(params[:id])
  end

  def spare_part_params
    params.require(:spare_part).permit(
      :generation_id,
      :phone_id,
      :mod_id,
      :name,
      :manufacturer,
      :images_cache,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
