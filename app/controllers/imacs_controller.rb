class ImacsController < ApplicationController

  before_action :set_imac, only: %i[ show edit update destroy ]

  def index
    @imacs = Imac.all
  end

  def show; end
  def edit; end

  def new
    @imac = Imac.new
  end

  def create
    @imac = Imac.new(imac_params)

    respond_to do |format|
      if @imac.save
        format.html { redirect_to @imac, notice: "Imac was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @imac.update(imac_params)
        format.html { redirect_to @imac, notice: "Imac was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @imac.destroy

    respond_to do |format|
      format.html { redirect_to imacs_url, notice: "Imac was successfully destroyed." }
    end
  end

  private

  def set_imac
    @imac = Imac.find(params[:id])
  end

  def imac_params
    params.require(:imac).permit(
      :user_id,
      :title,
      :diagonal,
      :model,
      :version,
      :series,
      :production_period,
      :full_title,
      :overview,
      :images_cache,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
