class Phone < ApplicationRecord
  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_rich_text :model_overview

  has_and_belongs_to_many :owned_gadgets

  belongs_to :generation

  has_one  :model

  has_many :users
  has_many :defects
  has_many :mods
  has_many :spare_parts
  has_many :cources
  has_many :repairs
  has_many :models, dependent: :destroy

  validates :model_title, presence: true
end
