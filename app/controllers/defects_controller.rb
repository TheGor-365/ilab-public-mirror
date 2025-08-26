class DefectsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_defect, only: %i[ show edit update destroy ]

  def index
    @defects = Defect.all
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
      :images_cache,
      :avatar,
      :avatar_cache,
      { modules: [] },
      { images: [] },
      { videos: [] }
    )
  end
end
