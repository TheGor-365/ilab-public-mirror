class Phone < ApplicationRecord
  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  before_validation :ensure_generation!, on: :create

  has_rich_text :model_overview

  has_and_belongs_to_many :owned_gadgets

  belongs_to :generation, optional: false

  has_one  :model

  has_many :users
  has_many :defects
  has_many :mods
  has_many :spare_parts
  has_many :cources
  has_many :repairs
  has_many :models, dependent: :destroy

  validates :model_title, presence: true

  private

  def ensure_generation!
    return if generation_id.present?

    possible = %i[title name model model_title label]
    attr = possible.find { |a| self.class.column_names.include?(a.to_s) && self[a].present? }
    return if attr.nil?

    title = self[attr]
    family = 'iPhone'

    self.generation = Generation.find_or_create_by!(title:) do |g|
      g.family = family if g.respond_to?(:family) && g.family.blank?
    end
  end
end
