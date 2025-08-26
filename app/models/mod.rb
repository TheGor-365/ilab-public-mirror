class Mod < ApplicationRecord

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :generation
  belongs_to :phone
  belongs_to :model
  
  has_and_belongs_to_many :defects
  has_and_belongs_to_many :repairs

  has_many :spare_parts

end
