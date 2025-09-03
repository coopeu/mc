# frozen_string_literal: true

class Lider < ApplicationRecord
  belongs_to :user
  belongs_to :sortide
end
