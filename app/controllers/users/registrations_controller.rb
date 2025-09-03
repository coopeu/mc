# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :authenticate_user!, only: [:update]
    before_action :configure_account_update_params, only: [:update]
    # prepend_before_action :check_captcha, only: [:create] # Change this to be any actions you want to protect.

    # GET /resource/sign_up
    def new
      build_resource({})
      resource.build_puntsini
      respond_with resource
    end

    # GET /resource/edit
    def edit
      super
    end

    def create
      super do |resource|
        if resource.persisted?
          AdminMailer.new_user_registered(resource).deliver_now unless resource.approved?
          UserMailer.with(user: resource).benvinguda_email(resource).deliver_now
          redirect_to benvinguda_path(
            user: resource,
            nom: resource.nom,
            moto_model: resource.moto_model,
            municipi: resource.municipi,
            tipus_carnet: resource.puntsini&.tipus_carnet,
            anys_carnet: resource.puntsini&.anys_carnet,
            kms: resource.puntsini&.kms,
            num_sortides: resource.puntsini&.num_sortides,
            grau_esportiu: resource.puntsini&.grau_esportiu
          ) and return
        else
          flash.now[:alert] = 'Error creating account.'
          render action: 'new'
        end
      end
    end

    # PUT /resource
    def update
      @user = current_user
      if update_resource(@user, account_update_params)
        @user.avatar.attach(params[:user][:avatar]) if params[:user][:avatar].present?
        redirect_to user_path(@user), notice: 'Actualització exitosa.'
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit
      end
    end

    private

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up,
                                        keys: [:nom, :cognom1, :cognom2, :avatar, :moto_marca, :moto_model, :foto_moto, :provincia, :comarca, :municipi,
                                               :data_naixement, :presentacio, { puntsini_attributes: %i[tipus_carnet anys_carnet kms num_sortides grau_esportiu] }])
    end

    def after_sign_up_path_for(_resource)
      '/'
      # render 'partials/benvingut'
    end

    def update_resource(resource, params)
      if params[:password].blank? && params[:password_confirmation].blank?
        resource.update_without_password(params.except(:current_password))
      else
        resource.update(params)
      end
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update,
                                        keys: %i[nom cognom1 cognom2 avatar moto_marca moto_model foro_moto provincia comarca municipi data_naixement
                                                 presentacio avatar foto_moto mobil email])
    end
  end
end
