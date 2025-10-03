class ModsController < ApplicationController
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_mod, only: %i[ show edit update destroy ]

  def index
    scope = Mod.all
    scope = scope.where(generation_id: params[:generation_id]) if params[:generation_id].present?
    scope = scope.where(phone_id:      params[:phone_id])      if params[:phone_id].present?
    scope = scope.where(model_id:      params[:model_id])      if params[:model_id].present?

    if params[:product_id].present?
      scope = scope.joins(:products).where(products: { id: params[:product_id] })
    end

    @mods = scope.distinct.order(:id).page(params[:page]).per(24) rescue scope.limit(100)
  end

  def show; end

  def edit; end

  def new
    @mod = Mod.new
  end

  def create
    @mod = Mod.new(mod_params)

    respond_to do |format|
      if @mod.save
        format.html { redirect_to @mod, notice: "Module was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mod.update(mod_params)
        format.html { redirect_to @mod, notice: "Module was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mod.destroy
    respond_to do |format|
      # фикс: было modules_url (битая ссылка на несуществующий ресурс)
      format.html { redirect_to mods_url, notice: "Module was successfully destroyed." }
    end
  end

  private

  def set_mod
    @mod = Mod.find(params[:id])
  end

  def mod_params
    params.require(:mod).permit(
      :generation_id,
      :phone_id,
      :model_id,
      :name,
      :images_cache,
      :avatar,
      :avatar_cache,
      { manufacturers: [] },
      { images: [] },
      { videos: [] }
    )
  end
end
