# frozen_string_literal: true

class Ritme < ApplicationRecord
  has_many :sortideclasses, dependent: :destroy
  has_many :sortides, through: :sortideclasses
end
