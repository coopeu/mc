# frozen_string_literal: true

class Piulade < ApplicationRecord
  include Likeable
  include FileValidatable

  has_many :likes, as: :likeable
  has_many_attached :files

  belongs_to :user
  belongs_to :parent_piulade, class_name: 'Piulade', foreign_key: 'piulade_id', optional: true
  belongs_to :sortide, optional: true
  has_many :piulade_comments
  has_many :repiulades, class_name: 'Piulade'

  validates :body, length: { maximum: 640 }, allow_blank: false

  # File upload validations
  validates_multiple_image_attachments :files, max_files: 4, max_size: 3.megabytes

  def piulade_type
    if piulade_id.present? && body.present?
      'quote-piulade'
    elsif piulade_id.present?
      'repiulade'
    else
      'piulade'
    end
  end

  def body_character_count
    body.length
  end
end
