# frozen_string_literal: true

class PiuladeCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_piulade

  def create
    @comment = @piulade.comments.new(comment_params.merge(user: current_user))
    respond_to do |format|
      if @comment.save
        format.turbo_stream
      else
        format.html { redirect_to piulade_path(@piulade), alert: 'Reply could not be created' }
      end
    end
  end

  def destroy
    @comment = @piulade.comments.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to piulade_path(@piulade), notice: 'Comment was deleted' }
    end
  end

  private

  def comment_params
    params.expect(comment: [:body])
  end

  def set_piulade
    @piulade = Piulade.find(params[:piulade_id])
  end
end
