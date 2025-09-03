# frozen_string_literal: true

class WebhooksController < ActionController::API
  # POST /webhook/stripe
  def stripe
    payload = request.body.read
    sig_header = request.headers['Stripe-Signature'] || request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV.fetch('STRIPE_WEBHOOK_SECRET', nil)

    if endpoint_secret.blank?
      Rails.logger.error('Missing STRIPE_WEBHOOK_SECRET')
      return head :internal_server_error
    end

    begin
      event = Stripe::Webhook.construct_event(
        payload,
        sig_header,
        endpoint_secret
      )
    rescue JSON::ParserError => e
      Rails.logger.warn("Stripe webhook JSON parse error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.warn("Stripe signature verification failed: #{e.message}")
      return head :bad_request
    end

    handle_stripe_event(event)
    head :ok
  end

  private

  def handle_stripe_event(event)
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      handle_checkout_completed(session)
    when 'payment_intent.succeeded'
      # payment_intent = event['data']['object']
    else
      # Unhandled event types are acknowledged with 200 to prevent retries
    end
  end

  def handle_checkout_completed(session)
    customer_id = session['customer']
    price_id = session.dig('display_items', 0, 'price', 'id') || session.dig('lines', 'data', 0, 'price', 'id')
    user = User.find_by(stripe_customer_id: customer_id)
    return unless user && price_id

    plan = Plan.find_by(sku: price_id) || Plan.find_by(codi: price_id)
    return unless plan

    user.update!(plan_id: plan.id, subscription_started_at: Time.current, subscription_ends_at: 1.year.from_now)
  end
end
