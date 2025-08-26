class ModelsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_model, only: %i[ show edit update destroy ]

  def index
    @models = Model.all
  end

  def show; end
  def edit; end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(model_params)

    respond_to do |format|
      if @model.save
        format.html { redirect_to @model, notice: "Model was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to @model, notice: "Model was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @model.destroy
    respond_to do |format|
      format.html { redirect_to models_url, notice: "Model was successfully destroyed." }
    end
  end

  private

  def set_model
    @model = Model.find(params[:id])
  end

  def model_params
    params.require(:model).permit(
      :generation_id,
      :phone_id,
      :images_cache,
      :title,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
