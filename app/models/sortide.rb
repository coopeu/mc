# frozen_string_literal: true

class Sortide < ApplicationRecord
  include FileValidatable

  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true

  extend FriendlyId
  friendly_id :title, use: :slugged

  has_one :sortideclass, dependent: :destroy
  accepts_nested_attributes_for :sortideclass

  has_one :category, through: :sortideclass
  has_one :tipu, through: :sortideclass
  has_one :ritme, through: :sortideclass

  has_many :inscripcios
  has_many :users, through: :inscripcios

  has_one_attached :ruta_foto, dependent: :destroy
  has_rich_text :descripcio

  has_one_attached :ruta_gpx

  belongs_to :user, optional: true

  has_many :sortide_comments, dependent: :destroy
  has_many :piulades, dependent: :destroy
  # before_validation :generate_slug

  validates :start_date, presence: true
  validates :start_time, presence: true
  validates :start_point, presence: true
  validates :title, presence: true
  validates :descripcio, presence: true
  validates :Km, presence: true
  validates :slug, presence: true
  validates :max_inscrits, presence: true
  validates :min_inscrits, presence: true
  validates :num_dies, presence: true
  validates :fi_ndies, presence: true
  validates :oberta, inclusion: { in: [true, false] }
  validates :preu, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # File upload validations
  validates_image_attachment :ruta_foto, max_size: 5.megabytes
  validates_gpx_attachment :ruta_gpx

  extend FriendlyId

  friendly_id :title, use: :slugged

  def should_generate_new_friendly_id?
    title_changed? || slug.blank?
  end

  # def generate_slug
  #	if start_date.present? && title.present?
  #	  self.slug = "#{start_date.strftime('%Y%m%d')}_#{title[0, 25].gsub(/\b(a|la|el|en|i|els|les)\b/, '').gsub(/\s+/, '')}"
  #	end
  # end
  #
  #  def generate_slug
  #	if start_date.present? && title.present?
  #	  self.slug = "#{start_date.strftime('%Y%m%d')}_#{title[0, 25].gsub(/\b(a|la|el|en|i|els|les)\b/, '').gsub(/\s+/, '')}"
  #	  Rails.logger.debug "Generated slug: #{self.slug}"
  #	end
  #  end
  #
  private

  def set_defaults
    self.image_captions ||= []
  end
end
