class Cource < ApplicationRecord

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  belongs_to :university
  belongs_to :category
  belongs_to :phone
  belongs_to :model
  belongs_to :generation

  has_many :chapters
  has_many :quizzes

end
