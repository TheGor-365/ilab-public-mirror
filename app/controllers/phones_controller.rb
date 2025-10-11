class PhonesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_phone, only: %i[ show edit update destroy ]

  def index
    @phones = Phone.order('id ASC').all
  end

  def show; end
  def edit; end

  def new
    @phone = Phone.new
  end

  def create
    @phone = Phone.new(phone_params)
    @phone.user_ids = current_user.id if user_signed_in?

    respond_to do |format|
      if @phone.save
        format.html { redirect_to @phone, notice: "Phone was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @phone.update(phone_params)
        format.html { redirect_to @phone, notice: "Phone was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @phone.destroy

    respond_to do |format|
      format.html { redirect_to phones_url, notice: "Phone was successfully destroyed." }
    end
  end

  private

  def set_phone
    @phone = Phone.find(params[:id])
  end

  def phone_params
    params.require(:phone).permit(
      :generation_id,
      :model_title,
      :model_overview,
      :images_cache,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] }
    )
  end
end
