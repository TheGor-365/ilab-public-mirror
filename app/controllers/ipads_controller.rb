class IpadsController < ApplicationController

  before_action :set_ipad, only: %i[ show edit update destroy ]

  def index
    @ipads = Ipad.all
  end

  def show; end
  def edit; end

  def new
    @ipad = Ipad.new
  end

  def create
    @ipad = Ipad.new(ipad_params)

    respond_to do |format|
      if @ipad.save
        format.html { redirect_to @ipad, notice: "Ipad was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @ipad.update(ipad_params)
        format.html { redirect_to @ipad, notice: "Ipad was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @ipad.destroy

    respond_to do |format|
      format.html { redirect_to ipads_url, notice: "Ipad was successfully destroyed." }
    end
  end

  private

  def set_ipad
    @ipad = Ipad.find(params[:id])
  end

  def ipad_params
    params.require(:ipad).permit(
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
