# frozen_string_literal: true

class PagesController < ApplicationController
  invisible_captcha only: [], on_spam: :spam_detected
  def portada
    @subscriptor = Subscriptor.new
    # @sortides = Sortide.where('start_date >= ?', Date.today).order(start_date: :asc).limit(3)
    @sortides = if current_user&.admin? && params[:show_unapproved]
                  # Show all sortides including unapproved ones for admin
                  Sortide.where('start_date > ?', Time.current).order(start_date: :asc)
                else
                  # Show only approved sortides
                  Sortide.where('start_date > ? AND approved IS NOT NULL AND approved = ?', Time.current,
                                true).order(start_date: :asc)
                end
    @users = User.joins(:inscripcios)
                 .group('users.id')
                 .order('COUNT(inscripcios.id) ASC')
                 .limit(6)
  end

  def benvinguda
    @nom = params[:nom]
    @moto_model = params[:moto_model]
    @municipi = params[:municipi]
  end

  def home
    @subscriptor = Subscriptor.new
  end

  def faq; end

  def privacitat; end

  def cookies; end

  def termes; end

  def gracies; end

  def plans
    @plans = Plan.all
  end

  def nosaltres; end

  def club; end

  def css; end

  private

  def spam_detected
    redirect_to root_path, alert: 'SPAM detected'
  end
end
