# frozen_string_literal: true

class Sortideclass < ApplicationRecord
  belongs_to :category
  belongs_to :ritme
  belongs_to :tipu
  belongs_to :sortide
end
