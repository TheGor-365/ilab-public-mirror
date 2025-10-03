class Mod < ApplicationRecord
  include RepairableScopes

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :generation, optional: true
  belongs_to :device, polymorphic: true, optional: true
  belongs_to :phone, optional: true
  belongs_to :model, optional: true

  has_and_belongs_to_many :defects
  has_and_belongs_to_many :repairs

  has_many :spare_parts, dependent: :destroy

  has_many :product_mods, dependent: :destroy
  has_many :products, through: :product_mods
end
