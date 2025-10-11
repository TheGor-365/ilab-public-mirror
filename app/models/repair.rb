class Repair < ApplicationRecord
  include RepairableScopes

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_rich_text :description
  has_rich_text :overview

  # В схеме есть HABTM mods_repairs — используем HABTM
  has_and_belongs_to_many :mods
  has_and_belongs_to_many :defects
  belongs_to :device, polymorphic: true, optional: true
  has_and_belongs_to_many :phones

  belongs_to :generation, optional: true

  has_many :product_repairs, dependent: :destroy
  has_many :products, through: :product_repairs
end
