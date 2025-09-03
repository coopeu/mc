# frozen_string_literal: true

class Puntuacio < ApplicationRecord
  belongs_to :user

  def calculate_current_points
    numSortides = user.inscripcios.count
    numSortideComments = user.sortide_comments.count
    self.punts_act = punts_ini + (numSortides * 2) + (numSortideComments * 0.2)
    save
  end

  delegate :to_i, to: :punts_act

  private

  def set_initial_points
    self.punts_act = punts_ini
    save
  end

  def update_user_level
    self.punts_act ||= punts_ini
    user_level
  end

  def calculate_and_update_points
    self.punts_act = calculate_current_points
    user_level
    save
  end
end
