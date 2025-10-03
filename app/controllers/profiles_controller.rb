class ProfilesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user

  def profile_dashboard
  end

  def profile
    @posts = @user.posts
    @articles = @user.articles
  end

  def edit_profile
  end

  def update
    if @user.update!(user_params)
      @user.save

      redirect_to account_path(@user), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :login,
      :username,
      :first_name,
      :last_name,
      {owned_gadgets: []},
      :borned,
      :repairman,
      :teacher,
      :student,
      :email,
      :password,
      :avatar,
      :avatar_cache,
      :password_confirmation,
      :remember_me,
      :images_cache,
      { images: [] },
      { videos: [] },
      phone_ids: [],
      makbook_ids: [],
      imac_ids: [],
      ipad_ids: [],
      airpod_ids: [],
      apple_watch_ids: []
    )
  end
end
