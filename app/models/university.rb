class University < ApplicationRecord

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_many :cources

end
