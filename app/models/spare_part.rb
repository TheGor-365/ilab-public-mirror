class SparePart < ApplicationRecord
  include RepairableScopes

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :generation, optional: true
  belongs_to :device, polymorphic: true, optional: true
  belongs_to :phone,  optional: true
  belongs_to :mod

  has_many :product_spare_parts, dependent: :destroy
  has_many :products, through: :product_spare_parts
end
