# frozen_string_literal: true

class Plan < ApplicationRecord
  has_many :users

  validates :nom, :preu, :interval, :specs, :detalls, :inscripcio, :sortides, :codi, :sku, presence: true
end
