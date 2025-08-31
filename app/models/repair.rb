class Repair < ApplicationRecord

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_rich_text :description
  has_rich_text :overview

  has_many :mods
  
  has_and_belongs_to_many :defects
  has_and_belongs_to_many :phones

  belongs_to :generation

end
