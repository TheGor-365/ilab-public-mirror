class CourcesController < ApplicationController

  before_action :set_cource, only: %i[ show edit update destroy ]

  def index
    @cources = Cource.all
  end

  def show; end
  def edit; end

  def new
    @cource = Cource.new
  end

  def create
    @cource = Cource.new(cource_params)

    respond_to do |format|
      if @cource.save
        format.html { redirect_to @cource, notice: "Cource was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cource.update(cource_params)
        format.html { redirect_to @cource, notice: "Cource was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cource.destroy
    respond_to do |format|
      format.html { redirect_to cources_url, notice: "Cource was successfully destroyed." }
    end
  end

  private

  def set_cource
    @cource = Cource.find(params[:id])
  end

  def cource_params
    params.require(:cource).permit(
      :university_id,
      :category_id,
      :generation_id,
      :model_id,
      :author,
      :name,
      :description,
      :price,
      :avatar,
      :images_cache,
      :avatar_cache,
      { chapters: [] },
      { images: [] },
      { videos: [] }
    )
  end
end
