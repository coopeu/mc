# frozen_string_literal: true

class User < ApplicationRecord
  include FileValidatable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :plan
  attr_accessor :stripe_customer_id
  attr_accessor :stripe_id, :stripe_email

  has_one_attached :avatar
  has_one_attached :foto_moto
  has_one :puntsini, class_name: 'Puntsini', dependent: :destroy
  accepts_nested_attributes_for :puntsini
  has_one :puntuacio, dependent: :destroy

  # The has_many :through Association
  has_many :inscripcios, class_name: 'Inscripcio', dependent: :destroy
  has_many :sortides, through: :inscripcios
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower
  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
  has_many :purchases
  has_many :posts
  has_many :sortide_comments, dependent: :destroy
  has_many :comandes
  has_many :credit_cards, dependent: :destroy
  has_many :purchases_pagaments
  has_many :messages
  has_many :piulades
  has_many :piulade_comments

  validates :nom, :cognom1, :cognom2, :moto_marca, :moto_model, :provincia, :comarca, :municipi, presence: true
  validates :nom, :cognom1, :cognom2, length: { minimum: 2 }
  validates :moto_marca, :moto_model, length: { minimum: 3 }
  validates :data_naixement, :mobil, :email, presence: true
  validates :mobil, :email, :slug, uniqueness: true
  validates :presentacio, presence: true, length: { maximum: 5000 }

  # File upload validations using the FileValidatable concern
  validates_image_attachment :avatar, max_size: 3.megabytes
  validates_image_attachment :foto_moto, max_size: 3.megabytes

  after_validation :geocode, if: :address_changed?
  after_create :create_puntuacio
  after_create :create_stripe_customer

  # Geocoding for map
  geocoded_by :full_address

  def follow(user)
    following_relationships.create(following_id: user.id)
  end

  def unfollow(user)
    following_relationships.find_by(following_id: user.id).destroy
  end

  def following?(user)
    following.include?(user)
  end

  extend FriendlyId

  friendly_id :slug_candidates, use: :slugged

  # Define your slug candidates
  def slug_candidates
    [
      :nom,
      [:nom, :cognom1],
      %i[nom cognom1 cognom2]
    ]
  end

  private

  def create_puntuacio
    ActiveRecord::Base.transaction do
      # Calculate initial puntuacio and determine escalafo and level
      initial_puntuacio = calculate_initial_puntuacio
      escalafo, user_level = calculate_escalafo_and_level(initial_puntuacio)
      # Create a new Puntuacio record
      Puntuacio.create!(
        user_id: id,
        punts_ini: initial_puntuacio,
        punts_act: initial_puntuacio,
        escalafo: escalafo,
        user_level: user_level,
        calculated_at: Time.zone.now # Set calculated_at to the current time
      )
    rescue StandardError => e
      # Handle other exceptions (e.g., log the error, notify admins)
      Rails.logger.error("Failed to create puntuació: #{e.message}")
      raise ActiveRecord::Rollback
    end
  end

  def calculate_initial_puntuacio
    if puntsini.nil?
      Rails.logger.error('Puntsini is not associated with the user.')
      return 0
    end
    # Convert string attributes to integers
    tipus_carnet = puntsini.tipus_carnet.to_i
    anys_carnet = puntsini.anys_carnet.to_i
    kms = puntsini.kms.to_i
    num_sortides = puntsini.num_sortides.to_i
    grau_esportiu = puntsini.grau_esportiu.to_i
    # Log the values of puntsini attributes
    Rails.logger.debug('Calculating initial puntuacio with the following values:')
    Rails.logger.debug { "tipus_carnet: #{tipus_carnet}" }
    Rails.logger.debug { "anys_carnet: #{anys_carnet}" }
    Rails.logger.debug { "kms: #{kms}" }
    Rails.logger.debug { "num_sortides: #{num_sortides}" }
    Rails.logger.debug { "grau_esportiu: #{grau_esportiu}" }
    (tipus_carnet * 10) +
      (anys_carnet * 2) +
      (kms * 4) +
      (num_sortides * 6) +
      (grau_esportiu * 5)
  end

  def calculate_escalafo_and_level(points)
    case points
    when 0..22
      ['1', 'Principiant']
    when 23..49
      ['2', 'Novell']
    when 50..74
      ['3', 'Avancat']
    when 75..89
      ['4', 'Experimentat']
    when 90..100
      ['5', 'Expert']
    else
      ['Unknown', 'Unknown Level']
    end
  end

  def create_stripe_customer
    return if stripe_customer_id.present?

    ActiveRecord::Base.transaction do
      # Create a new Stripe customer
      stripe_customer = Stripe::Customer.create(email: email)
      # Update the user record with the Stripe customer ID
      update!(
        stripe_customer_id: stripe_customer.id,
        stripe_email: stripe_customer.email # Assuming stripe_email is a separate field
      )
    rescue Stripe::APIConnectionError => e
      Rails.logger.error("Network error while creating Stripe customer: #{e.message}")
      raise ActiveRecord::Rollback
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error("Invalid request while creating Stripe customer: #{e.message}")
      raise ActiveRecord::Rollback
    rescue StandardError => e
      # Handle other exceptions (e.g., log the error, notify admins)
      Rails.logger.error("Failed to create Stripe customer: #{e.message}")
      raise ActiveRecord::Rollback
    end
  end

  def full_address
    # More specific address format for better geocoding
    if municipi.present? && comarca.present?
      "#{municipi}, #{comarca}, #{provincia}, Catalunya, Spain"
    elsif municipi.present?
      "#{municipi}, #{provincia}, Catalunya, Spain"
    else
      "#{provincia}, Catalunya, Spain"
    end
  end

  def address_changed?
    municipi_changed? || comarca_changed? || provincia_changed?
  end

  def active_subscription?
    subscription_ends_at.present? && subscription_ends_at > Time.zone.now
  end
end
