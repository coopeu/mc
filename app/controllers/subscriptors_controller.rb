# frozen_string_literal: true

class SubscriptorsController < ApplicationController
  invisible_captcha only: [:create], on_spam: :spam_detected

  def new
    @subscriptor = Subscriptor.new
  end

  def create
    @subscriptor = Subscriptor.new(subscriptor_params)

    if @subscriptor.save
      flash[:notice] = t('.success', email: @subscriptor.email)
      redirect_to root_path
    else
      flash[:alert] = t('.failure')
    end
  end

  private

  def subscriptor_params
    params.expect(subscriptor: [:email])
  end

  def spam_detected
    # The error is in this line:
    # flah[alert:] = t("subscriptors.spam_detected")
    # Correct syntax should be:
    flash[:alert] = t('subscriptors.spam_detected', default: 'Spam detected')
    redirect_to root_path
    # Optionally, you can log this spam attempt
    logger.warn "Possible spam submission detected for email: #{params[:subscriptor][:email]}"
  end
end
