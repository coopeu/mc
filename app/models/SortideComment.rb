# frozen_string_literal: true

class SortideComment < ApplicationRecord
  belongs_to :user
  belongs_to :sortide
  validates :content, presence: true
end
