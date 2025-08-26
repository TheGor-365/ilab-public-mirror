# frozen_string_literal: true
class Product < ApplicationRecord
  # --- Uploaders
  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  # --- Основные связи
  belongs_to :category,   optional: true
  belongs_to :phone,      optional: true
  belongs_to :generation, optional: true
  belongs_to :model,      optional: true

  # Производные коллекции от generation
  has_many :defects,     through: :generation
  has_many :repairs,     through: :generation
  has_many :spare_parts, through: :generation
  has_many :mods,        through: :generation

  # Делает генерацию обязательной (для не-draft)
  validates :generation, presence: true, unless: -> { respond_to?(:draft?) && draft? }
  validates :storage,    presence: true
  validates :color,      presence: true
  validates :price,      numericality: { greater_than: 0 }

  before_validation :resolve_catalog_context

  def display_name
    base = generation&.title.presence || name
    [base, storage, color].compact.join(" ")
  end

  # --- Состояния (чтобы не падало humanize)
  CONDITIONS = { new: 0, used: 1, for_parts: 2, refurbished: 3 }.freeze
  STATES     = { draft: 0, active: 1, paused: 2, sold: 3, archived: 4 }.freeze

  enum :condition, CONDITIONS, prefix: true
  enum :state,     STATES,     prefix: true

  # --- Безопасные human-хелперы
  def condition_human = humanize_enum(read_attribute(:condition), CONDITIONS)
  def state_human     = humanize_enum(read_attribute(:state), STATES)

  validates :generation, presence: true, unless: -> { respond_to?(:draft?) && draft? }

  def store_group
    # Если есть явная категория — используем её, иначе поколение
    respond_to?(:category) && category.present? ? category : generation
  end

  def resolve_relations_by_name
    title = name.to_s.strip
    return { model: nil, phone: nil, generation: nil } if title.blank?

    model = Model.find_by("LOWER(title) = ?", title.downcase) ||
            Model.where("title ILIKE ?", "%#{title}%").first

    phone = Phone.find_by("LOWER(model_title) = ?", title.downcase) ||
            Phone.where("model_title ILIKE ?", "%#{title}%").first

    generation = Generation.find_by("LOWER(title) = ?", title.downcase) ||
                 Generation.where("title ILIKE ?", "%#{title}%").first

    generation ||= phone&.generation || model&.phone&.generation
    { model: model, phone: (phone || model&.phone), generation: generation }
  end

  # --- Фолбэк (по старой логике: по заголовку/heading)
  # Можно вызывать, если FK пусты — вернёт найденные объекты, но не сохранит их.
  def resolve_relations_by_heading
    title = heading.to_s.strip
    return { model: nil, phone: nil, generation: nil } if title.blank?

    model = Model.find_by("LOWER(title) = ?", title.downcase) ||
            Model.where("title ILIKE ?", "%#{title}%").order(:id).first

    phone = phone || model&.phone || Phone.find_by("LOWER(model_title) = ?", title.downcase)
    generation = generation || model&.generation || phone&.generation

    { model: model, phone: phone, generation: generation }
  end

  def images = super || []
  def videos = super || []

    # Универсально берём название модели товара из доступных полей.
  # Возвращает строку или nil. Не падает, если колонки нет.
  def match_title_for_catalog
    %i[name title model_name heading].each do |col|
      next unless has_attribute?(col)
      val = self[col]
      return val.to_s if val.present?
    end
    nil
  end

  # 🔧 исправлено: всегда возвращаем один объект или nil, без возврата массива
  def resolve_relations_by_heading
    title = match_title_for_catalog.to_s.strip
    return { model: nil, phone: nil, generation: nil } if title.blank?

    model = Model.find_by("LOWER(title) = ?", title.downcase) ||
            Model.where("title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(title)}%").order(:id).first

    phone = self.phone ||
            model&.try(:phone) ||
            Phone.find_by("LOWER(model_title) = ?", title.downcase) ||
            Phone.where("model_title ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(title)}%").order(:id).first

    generation = self.generation ||
                 model&.try(:generation) ||
                 phone&.try(:generation) ||
                 find_generation_by_title(title)

    { model: model, phone: phone, generation: generation }
  end

  private

  def resolve_catalog_context
    # Если generation не выбран, попробуем распарсить name (для обратной совместимости)
    if generation_id.blank? && name.present? && respond_to?(:resolve_relations_by_name)
      ctx = resolve_relations_by_name
      self.generation ||= ctx[:generation]
      self.phone      ||= ctx[:phone]
      self.model      ||= ctx[:model]
    end

    # Собирать name из каталога + атрибутов вариантов
    if generation.present?
      self.name = [generation.title, storage, color].compact.join(" ")
    end
  end

  # ✅ возвращает один Generation или nil
  def find_generation_by_title(title)
    cols = %w[title name code] & Generation.column_names
    cols.each do |col|
      gen = Generation.find_by("LOWER(#{col}) = ?", title.downcase)
      return gen if gen
      gen = Generation.where("#{col} ILIKE ?", "%#{ActiveRecord::Base.sanitize_sql_like(title)}%")
                      .order(:id).first
      return gen if gen
    end
    nil
  end

  def humanize_enum(value, mapping)
    return if value.nil?
    if value.is_a?(Integer)
      key = mapping.key(value)
      key ? key.to_s.humanize : value.to_s
    else
      value.to_s.humanize
    end
  end
end
