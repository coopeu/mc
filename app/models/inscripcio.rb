# frozen_string_literal: true

class Inscripcio < ApplicationRecord
  belongs_to :user
  belongs_to :sortide
  validates :user_id,
            uniqueness: { scope: :sortide_id, message: 'Només et pots inscriure un cop. Si aneu dos comunica-ho SUP!' }
end
