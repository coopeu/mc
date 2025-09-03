# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :sortideclasses, dependent: :destroy
  has_many :sortides, through: :sortideclasses
end
