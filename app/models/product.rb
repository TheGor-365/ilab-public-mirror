# frozen_string_literal: true
class Product < ApplicationRecord
  # Uploaders
  mount_uploader  :avatar,  AvatarUploader
  mount_uploaders :images,  ImageUploader
  mount_uploaders :videos,  VideosUploader

  # Связи
  belongs_to :category,   optional: true
  belongs_to :phone,      optional: true
  belongs_to :generation, optional: true
  belongs_to :model,      optional: true
  belongs_to :seller,     class_name: "User", optional: true

  has_many :defects,     through: :generation
  has_many :repairs,     through: :generation
  has_many :spare_parts, through: :generation
  has_many :mods,        through: :generation

  # Состояния/статусы
  CONDITIONS = { new: 0, used: 1, for_parts: 2, refurbished: 3 }.freeze
  STATES     = { draft: 0, active: 1, paused: 2, sold: 3, archived: 4 }.freeze
  enum :condition, CONDITIONS, prefix: true
  enum :state,     STATES,     prefix: true

  # Валидации — строгие для не-draft
  with_options unless: -> { state_draft? } do
    validates :generation, presence: true
    validates :storage,    presence: true
    validates :color,      presence: true
    validates :price,      numericality: { greater_than: 0 }
  end

  # Бизнес-логика: собрать name и подтянуть каталожные связи
  before_validation :resolve_catalog_context
  before_validation :normalize_display_name

  # Scope'ы (для витрины и маркетплейса)
  scope :ready_for_store, -> {
    where.not(generation_id: nil)
      .where.not(storage: [nil, ""])
      .where.not(color:   [nil, ""])
      .where("price > 0")
  }
  scope :active_for_sale, -> { ready_for_store.where(state: states[:active]) }
  scope :by_family, ->(family) {
    joins(:generation).where(generations: { family: family }) if family.present?
  }

  # Отображаемое имя
  def display_name
    base = generation&.title.presence || self[:name]
    [base, storage, color].compact.join(" ").squish
  end

  def condition_human = humanize_enum(read_attribute(:condition), CONDITIONS)
  def state_human     = humanize_enum(read_attribute(:state),     STATES)

  # Для группировки на витрине
  def store_group
    category.presence || generation
  end

  # Картинки/видео — безопасные фолбэки
  def images = super || []
  def videos = super || []

  private

  # 1) обратная совместимость: если generation пуст — пробуем распознать по названию через сервис
  # 2) если generation есть — подставим phone/model по нему (если пусты)
  def resolve_catalog_context
    if generation_id.blank?
      ctx = CatalogResolver.resolve(match_title_for_catalog)
      if ctx
        self.generation ||= ctx[:generation]
        self.phone      ||= ctx[:phone]
        self.model      ||= ctx[:model]
      end
    else
      self.phone ||= generation&.phone
      self.model ||= generation && Model.find_by(generation_id: generation_id, phone_id: phone_id, title: generation.title)
    end
  end

  # Единая точка сборки name из каталога
  def normalize_display_name
    self.name = display_name if generation.present?
  end

  # Универсальный источник заголовка для резолва (назад совместимо)
  def match_title_for_catalog
    %i[name title model_name heading].find do |col|
      return self[col].to_s if has_attribute?(col) && self[col].present?
    end
    nil
  end

  def humanize_enum(value, mapping)
    return if value.nil?
    value.is_a?(Integer) ? (mapping.key(value)&.to_s&.humanize || value.to_s) : value.to_s.humanize
  end
end
