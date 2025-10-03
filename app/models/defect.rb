class Defect < ApplicationRecord
  include RepairableScopes

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_rich_text :description

  # HABTM (есть таблицы)
  has_and_belongs_to_many :phones
  has_and_belongs_to_many :repairs
  has_and_belongs_to_many :mods

  # Прямые внешние ключи из таблицы defects
  belongs_to :generation, optional: true
  belongs_to :device, polymorphic: true, optional: true
  belongs_to :phone,  optional: true

  # Запчасти идут через модули
  has_many :spare_parts, through: :mods

  # Обратная связь к продуктам через join
  has_many :product_defects, dependent: :destroy
  has_many :products, through: :product_defects
end
