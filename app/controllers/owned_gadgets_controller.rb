class OwnedGadgetsController < ApplicationController

  before_action :set_phone,        only: %i[ show edit update destroy ]
  before_action :set_phones,       only: %i[ show edit update destroy ]
  before_action :set_owned_gadget, only: %i[ show edit update destroy ]

  def index
    @owned_gadgets = OwnedGadget.all
  end

  def show
    @user = current_user
  end

  def edit
  end

  def new
    @user = current_user

    @owned_gadget = OwnedGadget.new
  end

  def create
    @owned_gadget = OwnedGadget.new(owned_gadget_params)
    @owned_gadget.user_id = current_user.id if user_signed_in?

    respond_to do |format|
      if @owned_gadget.save
        format.html { redirect_to @owned_gadget, notice: "Owned gadget was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @user = current_user
    @owned_gadget.user_id = current_user.id if user_signed_in?

    respond_to do |format|
      if @owned_gadget.update(owned_gadget_params)
        format.html { redirect_to @owned_gadget, notice: "Owned gadget was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @owned_gadget.destroy

    respond_to do |format|
      format.html { redirect_to owned_gadgets_url, notice: "Owned gadget was successfully destroyed." }
    end
  end

  private

  def set_owned_gadget
    @owned_gadget = OwnedGadget.find(params[:id])
  end

  def set_phone
    @phone = Phone.find(params[:id])
  end

  def set_phones
    @phones = Phone.all
  end

  def owned_gadget_params
    params.require(:owned_gadget).permit(
      :user_id,
      :phone_id,
      :images_cache,
      :avatar,
      :avatar_cache,
      { images: [] },
      { videos: [] },
    )
  end
end
