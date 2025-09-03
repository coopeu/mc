# frozen_string_literal: true

class Product < ApplicationRecord
  include FileValidatable

  has_rich_text :description
  has_many_attached :images
  belongs_to :category, optional: true
  has_many :cart_items

  # File upload validations
  validates_multiple_image_attachments :images, max_files: 10, max_size: 5.megabytes
end
