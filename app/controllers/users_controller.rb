# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :configure_account_update_params, only: [:update]

  def index
    # @users = User.all.order(plan_id: :desc, id: :asc)
    @users = User.includes(:puntuacio).order('puntuacios.punts_act ASC')
  end

  def socis
    @users = User.all
  end

  def search
    @users = User.all
    @users = @users.where(provincia: params[:provincia_id]) if params[:provincia_id].present?
    @users = @users.where(comarca: params[:comarca_id]) if params[:comarca_id].present?
    @users = @users.where(municipi: params[:municipi_id]) if params[:municipi_id].present?
    render :index
  end

  def show
    @user = User.friendly.find(params[:id])
    @user = User.includes(:puntuacio).friendly.find(params[:id])
    @followers = @user.followers
    @following = @user.following
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Usuari no trobat!'
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def report
    @user = User.friendly.find(params[:id])
    # Assuming you have a method to send emails
    AdminReportUserMailer.report_user(@user, current_user).deliver_now
    redirect_to @user, notice: "Informat d'un inconvenient perfil d'usuari a l'admin."
  end

  private

  def user_params
    params.expect(user: %i[plan nom cognom1 cognom2 avatar moto_marca moto_model foto_moto
                           provincia comarca municipi data_naixement presentacio mobil email slug approved])
  end

  def configure_account_update_params
    params.expect(user: %i[plan nom cognom1 cognom2 avatar moto_marca moto_model foto_moto
                           provincia comarca municipi data_naixement presentacio mobil email slug approved])
  end

  def authenticate_user!
    return if user_signed_in?

    redirect_to restringit_path, alert: "Contingut restringit. S'ha d'identificar per accedir"
  end
end
