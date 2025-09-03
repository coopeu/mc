# frozen_string_literal: true

class ContactesController < ApplicationController
  # before_action :verify_recaptcha, only: [:create]

  def new
    @contacte = Contacte.new
  end

  def create
    @contacte = Contacte.new(contacte_params)

    # Check if the honeypot field was filled (likely a bot)
    if params[:website].present?
      # Silently fail for bots
      redirect_to root_path, notice: 'Missatge enviat correctament.'
      return
    end

    # Check if the form was submitted too quickly (less than 2 seconds)
    if Time.zone.now.to_i - params[:form_time].to_i < 2
      flash.now[:alert] = "El formulari s'ha enviat massa ràpid. Si us plau, torna-ho a provar."
      return render :new
    end

    # Verify the math captcha
    if params[:captcha_answer].to_i != session[:captcha_result]
      flash.now[:alert] = 'La verificació de seguretat ha fallat. Si us plau, torna-ho a provar.'
      return render :new
    end

    if @contacte.save
      # Success handling
      redirect_to root_path, notice: 'Missatge enviat correctament. Gràcies per contactar amb nosaltres!'
    else
      # Error handling
      render :new
    end
  end

  # def create
  #   @contacte = Contacte.new(contacte_params)
  #
  #   Rails.logger.debug "Contacte params: #{contacte_params.inspect}"
  #
  #   if @contacte.save
  #     Rails.logger.debug "Contacte saved successfully"
  #     nom = @contacte.nom
  #     email = @contacte.email
  #     telefon = @contacte.telefon
  #     missatge = @contacte.missatge
  #
  #     begin
  #       ContacteMailer.contacte_mailer(nom, email, telefon, missatge).deliver_now
  #       Rails.logger.debug "Email sent successfully"
  #       flash[:success] = 'Missatge rebut. Gràcies! Aviat et contestarem'
  #       redirect_to gracies_path
  #     rescue => e
  #       Rails.logger.error "Failed to send email: #{e.message}"
  #       flash[:error] = 'Error enviant el correu. Si us plau, torna-ho a provar.'
  #       redirect_to new_contacte_path
  #     end
  #   else
  #     Rails.logger.error "Failed to save contacte: #{@contacte.errors.full_messages.join(", ")}"
  #     flash[:error] = 'Error, no s\'ha rebut el missatge'
  #     redirect_to new_contacte_path
  #   end
  # end

  private

  def contacte_params
    params.expect(contacte: %i[nom email telefon missatge])
  end

  #  def verify_recaptcha
  #    token = params['g-recaptcha-response']
  #    unless token.present?
  #      Rails.logger.error "reCAPTCHA token missing"
  #      flash[:error] = 'Verificació reCAPTCHA fallida. Si us plau, torna-ho a provar.'
  #      redirect_to new_contacte_path
  #      return
  #    end
  #
  #    unless RecaptchaEnterpriseService.verify(token: token, action: 'contact_form')
  #      Rails.logger.error "reCAPTCHA verification failed"
  #      flash[:error] = 'Verificació reCAPTCHA fallida. Si us plau, torna-ho a provar.'
  #      redirect_to new_contacte_path
  #    end
  #  end
end
