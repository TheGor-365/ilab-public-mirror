class GenerationsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_generation, only: %i[ show edit update destroy ]
  before_action :set_generations,
  only: [
    :index,
    :generations_table,
    :generations_block,
    :generation_title,
    :generation_features,
    :generation_production_period,
    :generation_vulnerability,
    :edit_generation_title,
    :edit_generation_avatar,
    :edit_generation_production_period,
    :edit_generation_vulnerability,
    :change_generation_images,
    :change_generation_videos
  ]

  def index; end

  def generations_table
    respond_to do |format|
      format.js { render partial: 'generations_table', generations: @generations }
    end
  end
  def generations_block
    respond_to do |format|
      format.js { render partial: 'generations_block', generations: @generations }
    end
  end
  def generation_title
    respond_to do |format|
      format.js { render partial: 'generation_title', generation: @generation }
    end
  end
  def generation_features
    respond_to do |format|
      format.js { render partial: 'generation_features', generation: @generation }
    end
  end
  def generation_production_period
    respond_to do |format|
      format.js { render partial: 'generation_production_period', generation: @generation }
    end
  end
  def generation_vulnerability
    respond_to do |format|
      format.js { render partial: 'generation_vulnerability', generation: @generation }
    end
  end
  def edit_generation_title
    respond_to do |format|
      format.js { render partial: 'edit_generation_title', generation: @generation }
    end
  end
  def edit_generation_avatar
    respond_to do |format|
      format.js { render partial: 'edit_generation_avatar', generation: @generation }
    end
  end
  def edit_generation_production_period
    respond_to do |format|
      format.js { render partial: 'edit_generation_production_period', generation: @generation }
    end
  end
  def edit_generation_features
    respond_to do |format|
      format.js { render partial: 'edit_generation_features', generation: @generation }
    end
  end
  def edit_generation_vulnerability
    respond_to do |format|
      format.js { render partial: 'edit_generation_vulnerability', generation: @generation }
    end
  end
  def change_generation_images
    respond_to do |format|
      format.js { render partial: 'change_generation_images', generation: @generation }
    end
  end
  def change_generation_videos
    respond_to do |format|
      format.js { render partial: 'change_generation_videos', generation: @generation }
    end
  end

  def show; end
  def edit; end

  def new
    @generation = Generation.new
  end

  def create
    @generation = Generation.new(generation_params)

    respond_to do |format|
      if @generation.save
        format.html { redirect_to @generation, notice: "Generation was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @generation.update(generation_params)
        format.html { redirect_to @generation, notice: "Generation was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @generation.destroy
    respond_to do |format|
      format.html { redirect_to generations_url, notice: "Generation was successfully destroyed." }
    end
  end

  private

  def set_generation
    @generation = Generation.find(params[:id])
  end

  def set_generations
    @generations = Generation.order('id ASC').all
  end

  def generation_params
    params.require(:generation).permit(
      :phone_id,
      :title,
      :production_period,
      :features,
      :vulnerability,
      :images_cache,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
