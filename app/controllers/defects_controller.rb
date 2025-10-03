class DefectsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_defect, only: %i[ show edit update destroy ]

  def index
    scope = Defect.all
    scope = scope.where(generation_id: params[:generation_id]) if params[:generation_id].present?
    scope = scope.where(phone_id:      params[:phone_id])      if params[:phone_id].present?

    if params[:model_id].present?
      # если у Defect есть связь с модами — фильтруем по модели через них
      scope = scope.joins(:mods).where(mods: { model_id: params[:model_id] })
    end

    if params[:product_id].present?
      # через связь defects <-> products (через product_defects)
      scope = scope.joins(:products).where(products: { id: params[:product_id] })
    end

    @defects = scope.distinct.order(:id).page(params[:page]).per(24) rescue scope.limit(100)
  end

  def show; end

  def edit; end

  def new
    @defect = Defect.new
  end

  def create
    @defect = Defect.new(defect_params)

    respond_to do |format|
      if @defect.save
        format.html { redirect_to @defect, notice: "defect was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @defect.update(defect_params)
        format.html { redirect_to @defect, notice: "defect was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @defect.destroy

    respond_to do |format|
      format.html { redirect_to defects_url, notice: "defect was successfully destroyed." }
    end
  end

  private

  def set_defect
    @defect = Defect.find(params[:id])
  end

  def defect_params
    params.require(:defect).permit(
      :title,
      :description,
      :generation_id,  # ← добавил, чтобы можно было сохранять фильтруемое поле
      :phone_id,       # ← тоже добавил
      :images_cache,
      :avatar,
      :avatar_cache,
      { modules: [] },
      { images: [] },
      { videos: [] }
    )
  end
end
