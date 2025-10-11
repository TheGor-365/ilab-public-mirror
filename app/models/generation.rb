class Generation < ApplicationRecord
  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  alias_attribute :heading, :title

  has_rich_text :features
  has_rich_text :vulnerability

  has_many :defects
  has_many :repairs
  has_many :models
  has_many :mods
  has_many :cources
  has_many :spare_parts

  has_one :phone, dependent: :destroy

  validates :title, presence: true
  validates :family, presence: true

  scope :by_family, ->(f) { where(family: f) }
end
