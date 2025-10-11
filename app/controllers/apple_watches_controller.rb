class AppleWatchesController < ApplicationController

  before_action :set_apple_watch, only: %i[ show edit update destroy ]

  def index
    @apple_watches = AppleWatch.all
  end

  def show
  end

  def new
    @apple_watch = AppleWatch.new
  end

  def edit
  end

  def create
    @apple_watch = AppleWatch.new(apple_watch_params)

    respond_to do |format|
      if @apple_watch.save
        format.html { redirect_to @apple_watch, notice: "Apple watch was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @apple_watch.update(apple_watch_params)
        format.html { redirect_to @apple_watch, notice: "Apple watch was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @apple_watch.destroy

    respond_to do |format|
      format.html { redirect_to apple_watches_url, notice: "Apple watch was successfully destroyed." }
    end
  end

  private

  def set_apple_watch
    @apple_watch = AppleWatch.find(params[:id])
  end

  def apple_watch_params
    params.require(:apple_watch).permit(
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
