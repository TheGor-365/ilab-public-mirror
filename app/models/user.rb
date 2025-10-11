class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  mount_uploader  :avatar, AvatarUploader
  mount_uploaders :images, ImageUploader
  mount_uploaders :videos, VideosUploader

  has_many :posts
  has_many :articles
  has_many :answers
  has_many :owned_gadgets
  has_many :products, foreign_key: :seller_id, inverse_of: :seller, dependent: :nullify

  has_and_belongs_to_many :phones
  has_and_belongs_to_many :makbooks
  has_and_belongs_to_many :imacs
  has_and_belongs_to_many :ipads
  has_and_belongs_to_many :airpods
  has_and_belongs_to_many :apple_watches

  has_one :profile

  attr_writer :login

  def full_name
    "#{first_name} #{last_name}"
  end

  def all_gadgets
    gadgets = []
    gadgets << phones
    gadgets << makbooks
    gadgets << imacs
    gadgets << ipads
    gadgets << airpods
    gadgets << apple_watches
    gadgets.each { |gadget| gadget }
  end

  def login
    @login || self.username || self.email
  end

  def self.find_for_database_authentication(warden_conditions)

    conditions = warden_conditions.dup

    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  validate :validate_username

  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end
end
