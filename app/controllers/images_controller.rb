# frozen_string_literal: true

class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sortide
  before_action :set_image, only: %i[edit update destroy]
  before_action :authenticate_admin!, only: %i[new edit create update destroy]

  def new
    @image = @sortide.images.build
  end

  def edit
    @images = @sortide.images
  end

  def create
    @image = @sortide.images.build(image_params)
    if @image.save
      redirect_to @sortide, notice: 'Image was successfully uploaded.'
    else
      render :new
    end
  end

  def update
    if @image.update(image_params)
      redirect_to @sortide, notice: 'Image caption was successfully updated.'
    else
      render :edit
    end
  end

  #  def destroy
  #    @image.purge
  #    redirect_to @sortide, notice: 'Image was successfully deleted.'
  #  end
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to @sortide, notice: 'Image was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_sortide
    @sortide = Sortide.friendly.find(params[:sortide_id])
  end

  def set_image
    @image = @sortide.images.find(params[:id])
  end

  def image_params
    params.expect(image: [:file, :caption])
  end

  def update_caption(index, caption)
    captions = @sortide.image_captions || []
    captions[index] = caption
    @sortide.update(image_captions: captions)
  end

  def authenticate_admin!
    redirect_to root_path, alert: 'Not authorized' unless current_user.admin?
  end
end
