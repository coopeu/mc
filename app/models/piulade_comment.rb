# frozen_string_literal: true

class PiuladeComment < ApplicationRecord
  include Likeable

  belongs_to :user
  belongs_to :piulade
end
