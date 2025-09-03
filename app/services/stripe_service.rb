# frozen_string_literal: true

class StripeService
  def self.create_customer(user)
    customer = Stripe::Customer.create(
      email: user.email,
      metadata: { user_id: user.id }
    )
    user.update(stripe_id: customer.id, stripe_email: customer.email)
    customer
  end

  def self.create_subscription(user, plan_id)
    # Ensure customer exists
    customer = if user.stripe_id
                 Stripe::Customer.retrieve(user.stripe_id)
               else
                 create_customer(user)
               end

    # Create subscription
    Stripe::Subscription.create(
      customer: customer.id,
      items: [{ price: plan_id }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent']
    )
  end

  def self.create_ride_payment(user, ride, amount)
    # Ensure customer exists
    customer = if user.stripe_id
                 Stripe::Customer.retrieve(user.stripe_id)
               else
                 create_customer(user)
               end

    # Create payment intent
    Stripe::PaymentIntent.create(
      amount: (amount * 100).to_i, # Convert to cents
      currency: 'eur',
      customer: customer.id,
      metadata: {
        ride_id: ride.id,
        user_id: user.id
      }
    )
  end

  def self.handle_webhook(payload, sig_header)
    event = Stripe::Webhook.construct_event(
      payload, sig_header, Rails.configuration.stripe[:signing_secret]
    )

    case event.type
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'customer.subscription.updated'
      handle_subscription_updated(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    when 'payment_intent.succeeded'
      handle_payment_succeeded(event.data.object)
    end

    event
  end

  def self.handle_subscription_created(subscription)
    user = User.find_by(stripe_id: subscription.customer)
    return unless user

    user.update(plan_id: subscription.items.data[0].price.product)
  end

  def self.handle_subscription_updated(subscription)
    user = User.find_by(stripe_id: subscription.customer)
    return unless user

    return unless subscription.status == 'active'

    user.update(plan_id: subscription.items.data[0].price.product)
  end

  def self.handle_subscription_deleted(subscription)
    user = User.find_by(stripe_id: subscription.customer)
    return unless user

    user.update(plan_id: nil)
  end

  def self.handle_payment_succeeded(payment_intent)
    return unless payment_intent.metadata.ride_id

    ride = Ride.find_by(id: payment_intent.metadata.ride_id)
    return unless ride

    # Update ride payment status
    ride.update(paid: true)
  end
end
