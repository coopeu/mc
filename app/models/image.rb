# frozen_string_literal: true

class Image < ApplicationRecord
  include FileValidatable

  belongs_to :sortide
  has_one_attached :file

  # Use the comprehensive file validation from FileValidatable concern
  validates_image_attachment :file, required: true, max_size: 2.megabytes
end
