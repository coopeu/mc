# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :set_likeable

  def create
    if @likeable.likes.count >= 1 && @likeable.liked_by?(current_user)
      @like = Like.find_by(likeable_id: @likeable.id, user: current_user)
      @like.destroy
    else
      @like = @likeable.likes.new
      @like.user = current_user
      @like.save
    end
    respond_to do |format|
      format.html do
        redirect_to redirect_path, notice: 'Like ben creat.'
      end
      format.json { render json: { likes_count: @likeable.likes.count } }
    end
  end

  private

  def set_likeable
    allowed_types = %w[Piulade PiuladeComment]
    likeable_type = params[:likeable_type]

    unless allowed_types.include?(likeable_type)
      redirect_to root_path, alert: 'Invalid likeable type'
      return
    end

    @likeable = likeable_type.constantize.find(params[:likeable_id])
  end

  def redirect_path
    case @likeable
    when Piulade
      piulade_path(@likeable)
    when PiuladeComment
      piulade_path(@likeable.piulade)
    else
      root_path
    end
  end
end
