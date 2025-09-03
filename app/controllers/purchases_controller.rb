# frozen_string_literal: true

class PurchasesController < ApplicationController
  def show
    @purchase = Purchase.find_by(uuid: params[:id])
    @product = Product.find(@purchase.product_id)
    @user = User.find(@purchase.user_id)
    @sortide = Sortide.find(@purchase.product_id)

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: '<%= @purchase.uuid %>' # Excluding ".pdf" extension.
      end
    end
  end

  def create
    # Your logic for handling the form submission and Stripe charge goes here

    # Assuming you have a method to handle the Stripe payment
    if process_stripe_payment
      # Create a new PurchasesInscripcion record
      @inscripcio = PurchasesInscripcion.create(
        product: @product,
        user: current_user
        # Add any other necessary attributes here
      )

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
  end

  private

  def process_stripe_payment
    # Your logic to process the Stripe payment
    # Return true if successful, false otherwise
  end
end
