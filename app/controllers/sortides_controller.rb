# frozen_string_literal: true

class SortidesController < ApplicationController
  include UserHelper

  # Require authentication for viewing a sortida
  before_action :authenticate_user!, only: %i[show]
  before_action :check_user_level, only: [:create]
  before_action :set_sortide, only: %i[show edit update destroy create_sortide_comment]
  before_action :set_sortideclasses, only: %i[edit update]
  before_action :set_user, only: [:show]
  before_action :ensure_avatar_and_foto_moto, only: [:inscribe]

  def index
    # @sortides = Sortide.where('start_date >= ?', Date.today).order(start_date: :asc)
    # @sortides = Sortide.where('start_date > ? AND approved = ?', Time.current).order(start_date: :asc)
    # OK  @sortides = Sortide.where('start_date > ? AND approved IS NOT NULL AND approved = ?', Time.current, true).order(start_date: :asc)
    @sortides = if current_user&.admin? && params[:show_unapproved]
                  # Show all sortides including unapproved ones for admin
                  Sortide.where('start_date > ?', Time.current).order(start_date: :asc)
                else
                  # Show only approved sortides
                  Sortide.where('start_date > ? AND approved IS NOT NULL AND approved = ?', Time.current,
                                true).order(start_date: :asc)
                end
    @sortideclasses = Sortideclass.where(sortide_id: @sortides.pluck(:id)).includes(:category, :ritme, :tipu)
    @categories = @sortideclasses.map(&:category)
    @ritmes = @sortideclasses.map(&:ritme)
    @tipus = @sortideclasses.map(&:tipu)

    if params[:category_id].present?
      @sortides = @sortides.joins(:sortideclass).where(sortideclasses: { category_id: params[:category_id] })
    end
    if params[:tipu_id].present?
      @sortides = @sortides.joins(:sortideclass).where(sortideclasses: { tipu_id: params[:tipu_id] })
    end
    if params[:ritme_id].present?
      @sortides = @sortides.joins(:sortideclass).where(sortideclasses: { ritme_id: params[:ritme_id] })
    end
    @sortides = @sortides.includes(:sortideclass)
  end

  def show
    if user_signed_in?
      @discounted_price = calculate_discounted_price(current_user, @sortide)
      @inscripcio = current_user.inscripcios.find_by(sortide: @sortide)
      @comment = SortideComment.new
      @comments = @sortide.sortide_comments.includes(:user)
    end
    @sortideclasses = Sortideclass.where(sortide_id: @sortide.id).includes(:category, :ritme, :tipu)
    @categories = @sortideclasses.map(&:category)
    @ritmes = @sortideclasses.map(&:ritme)
    @tipus = @sortideclasses.map(&:tipu)
  end

  def new
    @sortide = Sortide.new
    @sortide.build_sortideclass
  end

  def edit
    @sortide.build_sortideclass if @sortide.sortideclass.nil?
    @sortideclasses = Sortideclass.where(sortide_id: @sortide.id).includes(:category, :ritme, :tipu)
    @categories = @sortideclasses.map(&:category)
    @ritmes = @sortideclasses.map(&:ritme)
    @tipus = @sortideclasses.map(&:tipu)
  end

  def create
    @sortide = Sortide.new(sortide_params)
    @sortide.user = current_user

    if @sortide.save
      # Puntuacio.create(user: current_user)
      # Lider.create(user_id: current_user.id, sortide_id: @sortide.id)
      # Only create a Lider record if the current user is not an admin
      Lider.create(user_id: current_user.id, sortide_id: @sortide.id) unless current_user.admin?
      AdminMailer.new_sortide_notification(@sortide).deliver_now unless current_user.admin?

      redirect_to @sortide, notice: 'Sortide ben creada.'
    else
      render :new
    end
  end

  def update
    # Check if the user_id is blank or set to "No Guide" and set it to 0
    if @sortide.update(sortide_params)
      redirect_to @sortide, notice: 'Sortida actualitzada.'
    else
      Rails.logger.debug { "Actualització fallida: #{@sortide.errors.full_messages.join(', ')}" }
      render :edit, status: :unprocessable_entity
    end
  end

  def inscribe
    @sortide = Sortide.friendly.find(params[:id])
    @inscripcio = @sortide.inscripcios.build(user: current_user)

    if @inscripcio.save
      AdminMailer.new_inscripcio(current_user, @sortide).deliver_now
      UserMailer.new_inscripcio(current_user, @sortide).deliver_now
      redirect_to @sortide, notice: 'Has estat ben Inscrit.'
    else
      redirect_to @sortide, alert: 'Error en la teva inscripció.'
    end
  end

  def destroy
    @sortide.destroy
    redirect_to sortides_path, notice: 'Sortida was successfully removed.'
  end

  def create_sortide_comment
    @comment = @sortide.sortide_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @sortide, notice: 'Commentari creat.'
    else
      @comments = @sortide.sortide_comments.includes(:user)
      flash.now[:alert] = 'El comentari no pot estar en blanc.' if @comment.errors[:content].include?("can't be blank")
      Rails.logger.debug { "Error al crear el comentari: #{@comment.errors.full_messages.join(', ')}" }
      redirect_to @sortide, notice: 'Commentari inexistent.'
    end
  end

  private

  def set_sortide
    @sortide = Sortide.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Sortida no trobada.'
  end

  def ensure_avatar_and_foto_moto
    return if current_user.avatar.attached? && current_user.foto_moto.attached?

    redirect_to edit_user_path(current_user),
                alert: "Ens falten les teves dos fotos, teva i de la teva moto per poder inscriure't."
  end

  def set_sortideclasses
    @sortideclasses = Sortideclass.all
  end

  def sortide_params
    params.expect(sortide: [:user_id, :title, :start_date, :slug, :start_time, :start_point, :ruta_foto,
                            :descripcio, :Km, :max_inscrits, :min_inscrits, :num_dies, :fi_ndies, :oberta, :preu, :approved, :ruta_gpx, :youtube, { sortideclass_attributes: %i[category_id tipu_id ritme_id] }])
  end

  def check_user_level
    return if current_user.puntuacio.to_i >= 3

    redirect_to root_path, alert: 'Ho sentim pero no tens el nivell de privilegis requerits.'
  end

  def set_user
    @user = current_user
  end

  def comment_params
    params.expect(sortide_comment: [:content])
  end

  # Avoid shadowing Devise's authenticate_user! helper
  def require_user_authentication
    return if user_signed_in?

    redirect_to restringit_path, alert: 'You must be signed in to view this content.'
  end
end
