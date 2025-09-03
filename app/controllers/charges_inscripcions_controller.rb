# frozen_string_literal: true

class ChargesInscripcionsController < ApplicationController
  def create
    @inscripcio = Inscripcio.new(inscripcio_params)
    if @inscripcio.save
      if process_stripe_payment
        # Send email to the user
        UserMailer.with(user: current_user, inscripcio: @inscripcio).inscripcio_confirmation.deliver_now
        # Send email to the admin
        AdminMailer.with(user: current_user, inscripcio: @inscripcio).new_inscripcio_notification.deliver_now
        # Redirect to the sortide page
        redirect_to sortide_path(@inscripcio.sortide), notice: 'Inscripcio completed successfully.'
      else
        # Handle payment failure
        redirect_to sortide_path(@inscripcio.sortide), alert: 'There was an issue with your payment. Please try again.'
      end
    else
      # Handle inscripcio save failure
      redirect_to sortide_path(@inscripcio.sortide), alert: 'There was an issue with your inscripcio. Please try again.'
    end
  end

  private

  def inscripcio_params
    params.expect(inscripcio: %i[sortide_id user_id other_attributes])
  end

  def process_stripe_payment
    # Your logic to process the Stripe payment
    # Return true if successful, false otherwise
  end
end
