class Category < ApplicationRecord
  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :device, polymorphic: true, optional: true
  has_many :products
  has_many :cources
  belongs_to :phone, optional: true

  def phone_by_heading
    Phone.find_by(model_title: heading)
  end
end
