class Post < ApplicationRecord

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_rich_text :body

  belongs_to :user

end
