# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :set_current_cart
  # Use exception to protect against CSRF by default. Explicitly skip in API/webhooks.
  protect_from_forgery with: :exception

  protected

  def check_admin_priv
    return if current_admin

    redirect_to root_path
  end

  def configure_permitted_parameters
    extra_keys  = [:nom, :cognom1, :cognom2, :moto_marca, :moto_model, :municipi, :comarca, :data_naixement, :mobil,
                   :email, :presentacio, :slug, { puntsini_attributes: %i[tipus_carnet anys_carnet kms num_sortides grau_esportiu] }]
    signup_keys = extra_keys + %i[card_token plan_id terms_of_service]
    # Allow custom fields for Devise flows
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password remember_me])
    devise_parameter_sanitizer.permit(:sign_up, keys: signup_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  private

  def set_current_cart
    if session[:current_cart_id]
      @current_cart = Cart.find_by(secret_id: session[:current_cart_id])
    else
      @current_cart = Cart.create
      session[:current_cart_id] = @current_cart.secret_id
    end
  end
end
