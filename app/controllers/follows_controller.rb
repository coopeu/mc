# frozen_string_literal: true

class FollowsController < ApplicationController
  before_action :authenticate_user!

  def follow
    user = User.friendly.find(params[:id])
    current_user.follow(user)
    redirect_to user_path(user), notice: 'Ara estas seguint aquest motorista.'
  end

  def unfollow
    user = User.friendly.find(params[:id])
    current_user.unfollow(user)
    redirect_to user_path(user), notice: 'Ara ja no segueixes aquest motorista.'
  end

  def report
    user = User.find(params[:id])
    # Add your reporting logic here
    AdminMailer.report_user(user, current_user).deliver_now
    redirect_to user_path(user), notice: "Has informat d'aquest motorista."
  end
end
