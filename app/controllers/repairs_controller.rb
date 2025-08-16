class RepairsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_repair, only: %i[ show edit update destroy ]

  def index
    @repairs = Repair.all
  end

  def show; end
  def edit; end

  def new
    @repair = Repair.new
  end

  def create
    @repair = Repair.new(repair_params)

    respond_to do |format|
      if @repair.save
        format.html { redirect_to @repair, notice: "Repair was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @repair.update(repair_params)
        format.html { redirect_to @repair, notice: "Repair was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repair.destroy
    respond_to do |format|
      format.html { redirect_to repairs_url, notice: "Repair was successfully destroyed." }
    end
  end

  private

  def set_repair
    @repair = Repair.find(params[:id])
  end

  def repair_params
    params.require(:repair).permit(
      :generation_id,
      :phone_id,
      :defect_id,
      :title,
      :spare_part,
      :description,
      :overview,
      :images_cache,
      :price,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
