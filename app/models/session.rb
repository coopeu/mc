# frozen_string_literal: true

class Session < ApplicationRecord
  belongs_to :user

  validates :login_time, presence: true
end
