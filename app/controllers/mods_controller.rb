class ModsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_mod, only: %i[ show edit update destroy ]

  def index
    @mods = Mod.all
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
      format.html { redirect_to modules_url, notice: "Module was successfully destroyed." }
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
