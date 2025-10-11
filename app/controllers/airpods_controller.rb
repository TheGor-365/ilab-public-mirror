class AirpodsController < ApplicationController

  before_action :set_airpod, only: %i[ show edit update destroy ]

  def index
    @airpods = Airpod.all
  end

  def show; end
  def edit; end

  def new
    @airpod = Airpod.new
  end

  def create
    @airpod = Airpod.new(airpod_params)

    respond_to do |format|
      if @airpod.save
        format.html { redirect_to @airpod, notice: "Airpod was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @airpod.update(airpod_params)
        format.html { redirect_to @airpod, notice: "Airpod was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @airpod.destroy

    respond_to do |format|
      format.html { redirect_to airpods_url, notice: "Airpod was successfully destroyed." }
    end
  end

  private

  def set_airpod
    @airpod = Airpod.find(params[:id])
  end

  def airpod_params
    params.require(:airpod).permit(
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
