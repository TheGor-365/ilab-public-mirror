# frozen_string_literal: true

class Product < ApplicationRecord
  include ProductSku

  mount_uploader  :avatar,  AvatarUploader
  mount_uploaders :images,  ImageUploader
  mount_uploaders :videos,  VideosUploader

  belongs_to :category,   optional: true
  belongs_to :phone,      optional: true
  belongs_to :generation, optional: true
  belongs_to :model,      optional: true
  belongs_to :seller,     class_name: "User", optional: true
  belongs_to :sku,        optional: true

  # Каталог (через поколение)
  has_many :gen_repairs,      through: :generation, source: :repairs
  has_many :gen_defects,      through: :generation, source: :defects
  has_many :gen_mods,         through: :generation, source: :mods
  has_many :gen_spare_parts,  through: :generation, source: :spare_parts

  has_many :sidebar_entries,           class_name: "ProductSidebarEntry",          foreign_key: :product_id
  has_many :sidebar_repairs,     -> { where(kind: "repair") },     class_name: "ProductSidebarEntry", foreign_key: :product_id
  has_many :sidebar_defects,     -> { where(kind: "defect") },     class_name: "ProductSidebarEntry", foreign_key: :product_id
  has_many :sidebar_mods,        -> { where(kind: "mod") },        class_name: "ProductSidebarEntry", foreign_key: :product_id
  has_many :sidebar_spare_parts, -> { where(kind: "spare_part") }, class_name: "ProductSidebarEntry", foreign_key: :product_id

  # Привязки к экземпляру
  has_many :product_repairs,     dependent: :destroy
  has_many :repairs,             through: :product_repairs
  has_many :product_defects,     dependent: :destroy
  has_many :defects,             through: :product_defects
  has_many :product_mods,        dependent: :destroy
  has_many :mods,                through: :product_mods
  has_many :product_spare_parts, dependent: :destroy
  has_many :spare_parts,         through: :product_spare_parts

  CONDITIONS = { new: 0, used: 1, for_parts: 2, refurbished: 3 }.freeze
  STATES     = { draft: 0, active: 1, paused: 2, sold: 3, archived: 4 }.freeze
  enum :condition, CONDITIONS, prefix: true
  enum :state,     STATES,     prefix: true

  with_options unless: -> { state_draft? } do
    validates :price, numericality: { greater_than: 0 }, presence: true
  end
  validate :sku_required_for_non_draft
  # убрали дефолтную uniqueness-валидацию, чтобы не срабатывала на draft
  validate :unique_sku_per_seller_unless_draft

  def unique_sku_per_seller_unless_draft
    return if state_draft? || sku_id.blank? || seller_id.blank?

    # проверяем конфликт только с НЕ-draft записями
    if Product.where(seller_id: seller_id, sku_id: sku_id)
              .where.not(id: id)
              .where.not(state: self.class.states[:draft])
              .exists?
      errors.add(:sku_id, "у вас уже есть опубликованное объявление с этим SKU")
    end
  end

  # Удобные геттеры из SKU
  delegate :generation_id, :phone_id, :storage, :color, to: :sku, prefix: true, allow_nil: true

  # Бизнес-логика / нормализация
  before_validation :assign_sku_from_attrs       # авто-назначаем sku по атрибутам
  before_validation :sync_variant_from_sku
  before_validation :normalize_blanks
  before_validation :resolve_catalog_context
  before_validation :normalize_display_name

  scope :ready_for_store, -> { where("price > 0") }
  scope :active_for_sale, -> { ready_for_store.where(state: states[:active]) }
  scope :by_family, ->(family) { family.present? ? joins(:generation).where(generations: { family: family }) : all }

  def display_name
    base = generation&.title.presence || self[:name]
    [base, storage, color].compact.join(" ").squish
  end

  def condition_human = humanize_enum(read_attribute(:condition), CONDITIONS)
  def state_human     = humanize_enum(read_attribute(:state),     STATES)

  def store_group
    category.presence || generation
  end

  # -------- Каталожные хелперы --------
  def catalog_repairs
    scope = Repair.left_outer_joins(:phones)
    clauses, binds = [], {}
    if generation_id.present?
      clauses << "repairs.generation_id = :gid"; binds[:gid] = generation_id
    end
    if phone_id.present?
      clauses << "repairs.phone_id = :pid OR phones.id = :pid"; binds[:pid] = phone_id
    end
    return Repair.none if clauses.empty?
    scope.where(clauses.join(' OR '), binds).distinct
  end

  def catalog_defects
    scope = Defect.left_outer_joins(:phones)
    clauses, binds = [], {}
    if generation_id.present?
      clauses << "defects.generation_id = :gid"; binds[:gid] = generation_id
    end
    if phone_id.present?
      clauses << "defects.phone_id = :pid OR phones.id = :pid"; binds[:pid] = phone_id
    end
    return Defect.none if clauses.empty?
    scope.where(clauses.join(' OR '), binds).distinct
  end

  def catalog_mods
    scope = Mod.all
    ors = []
    ors << scope.where(model_id: model_id) if model_id.present?
    ors << scope.where(phone_id: phone_id) if phone_id.present?
    ors << scope.where(generation_id: generation_id) if generation_id.present?
    return Mod.none if ors.empty?
    ors.reduce(&:or).distinct
  end

  def catalog_spare_parts
    rels = []
    rels << SparePart.joins(:mod).where(mods: { model_id: model_id }) if model_id.present?
    rels << SparePart.joins(:mod).where(mods: { phone_id: phone_id }) if phone_id.present?
    rels << SparePart.joins(:mod).where(mods: { generation_id: generation_id }) if generation_id.present?
    return SparePart.none if rels.empty?
    rels.reduce(&:or).distinct
  end

  def images = super || []
  def videos = super || []

  private

  # Авто-назначаем SKU по атрибутам (в dev можем создать недостающий)
  def assign_sku_from_attrs
    return if sku_id.present?
    return if generation_id.blank? || storage.blank? || color.blank?

    scope = Sku.where(generation_id: generation_id, storage: storage, color: color)
    sid = phone_id.present? ? scope.where(phone_id: phone_id).limit(1).pick(:id) : nil
    sid ||= scope.limit(1).pick(:id)

    if sid
      self.sku_id = sid
    elsif Rails.env.development?
      ph_id = phone_id || generation&.phone_id
      s = Sku.create!(generation_id: generation_id, phone_id: ph_id, storage: storage, color: color)
      self.sku_id = s.id
    end
  end

  # Зеркалим вариант из sku → в легаси-поля
  def sync_variant_from_sku
    return unless sku.present?
    if will_save_change_to_sku_id? || generation_id.nil? || phone_id.nil? || storage.nil? || color.nil?
      self.generation_id = sku.generation_id
      self.phone_id      = sku.phone_id
      self.storage       = sku.storage
      self.color         = sku.color
    end
  end

  def normalize_blanks
    self.storage = nil if storage.is_a?(String) && storage.strip == ""
    self.color   = nil if color.is_a?(String) && color.strip == ""
    self.name    = name.to_s.squish if self[:name].present?
  end

  def resolve_catalog_context
    if generation_id.blank?
      self.generation ||= phone&.generation
      self.generation ||= model&.generation
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

  def normalize_display_name
    self.name = display_name if generation.present?
  end

  def match_title_for_catalog
    %i[name title model_name heading].find { |col| return self[col].to_s if has_attribute?(col) && self[col].present? }
    nil
  end

  def humanize_enum(value, mapping)
    return if value.nil?
    value.is_a?(Integer) ? (mapping.key(value)&.to_s&.humanize || value.to_s) : value.to_s.humanize
  end

  def sku_required_for_non_draft
    errors.add(:sku, "must be present for non-draft") if !state_draft? && sku_id.blank?
  end
end
