# frozen_string_literal: true

class PiuladesController < ApplicationController
  before_action :authenticate_user! # Allowing piulades for all authenticated users ifnot restringit
  before_action :set_piulade, only: %i[edit update destroy]

  def index
    @piulade = Piulade.new
    @piulades = Piulade.order(created_at: :desc)
  end

  def show
    @piulade = Piulade.find(params[:id])
    @piulade_comment = PiuladeComment.new
    @piulade_comments = @piulade.piulade_comments.order(created_at: :desc)
  end

  def edit
    @piulade = Piulade.find(params[:id])
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @sortide = Sortide.friendly.find(params[:sortide_id])
    @piulade = Piulade.new(piulade_params)
    @piulade.sortide_id = @sortide.id
    @piulade.user = current_user

    respond_to do |format|
      if @piulade.save
        format.html { redirect_to @sortide, notice: 'Piulade was successfully created.' }
        format.json { render :show, status: :created, location: @piulade }
      else
        flash[:piulade_errors] = @piulade.errors.full_messages
        format.html { redirect_to @sortide }
        format.json { render json: @piulade.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @piulade.update(piulade_params)
      respond_to do |format|
        format.html { redirect_to @piulade, notice: 'Piulade was successfully updated.' }
        format.turbo_stream
      end
    else
      render :edit
    end
  end

  def destroy
    @piulade = current_user.piulades.find(params[:id])
    @piulade.destroy
    respond_to do |format|
      format.html { redirect_to piulades_path, notice: 'Piulada esborrada.' }
      format.turbo_stream
    end
  end

  def repiulade
    @piulade = Piulade.find(params[:id])

    @repiulade = current_user.piulades.new(piulade_id: @piulade.id)

    respond_to do |format|
      if @repiulade.save
        format.turbo_stream
      else
        format.html { redirect_back fallback_location: @piulade, alert: 'Could not repiulade' }
      end
    end
  end

  # app/controllers/piulades_controller.rb
  def remove_file
    @piulade = Piulade.find(params[:id])
    file = @piulade.files.find(params[:file_id])
    file.purge
    redirect_to edit_piulade_path(@piulade), notice: 'Fitxer eliminat amb exit.'
  end

  private

  def set_piulade
    @piulade = Piulade.find(params[:id])
  end

  def piulade_params
    params.expect(piulade: [:body, :content])
  end

  def authenticate_user!
    return if user_signed_in?

    redirect_to restringit_path, alert: "S'ha d'autenticar per accedir aquest contingut restringit."
  end
end
