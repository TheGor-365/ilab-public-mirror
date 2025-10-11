class MakbooksController < ApplicationController

  before_action :set_makbook, only: %i[ show edit update destroy ]

  def index
    @makbooks = Makbook.all
  end

  def show; end
  def edit; end

  def new
    @makbook = Makbook.new
  end

  def create
    @makbook = Makbook.new(makbook_params)

    respond_to do |format|
      if @makbook.save
        format.html { redirect_to @makbook, notice: "Makbook was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @makbook.update(makbook_params)
        format.html { redirect_to @makbook, notice: "Makbook was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @makbook.destroy

    respond_to do |format|
      format.html { redirect_to makbooks_url, notice: "Makbook was successfully destroyed." }
    end
  end

  private

  def set_makbook
    @makbook = Makbook.find(params[:id])
  end

  def makbook_params
    params.require(:makbook).permit(
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
