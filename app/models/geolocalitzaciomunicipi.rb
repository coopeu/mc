# frozen_string_literal: true

class Geolocalitzaciomunicipi < ApplicationRecord
  validates :municipi, presence: true, uniqueness: true
  validates :x, presence: true
  validates :y, presence: true

  # Returns coordinates as a hash
  def coordinates
    { lat: y, lng: x }
  end

  # Class method to find coordinates by municipi name
  def self.find_coordinates(municipi_name)
    find_by(municipi: municipi_name)&.coordinates
  end
end
