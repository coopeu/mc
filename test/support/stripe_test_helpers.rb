# frozen_string_literal: true

module StripeTestHelpers
  # Helper methods for Stripe testing
  
  def mock_stripe_customer_creation(customer_id = 'cus_test_123', email = 'test@example.com')
    customer = {
      id: customer_id,
      object: 'customer',
      email: email,
      created: Time.current.to_i
    }
    
    stub_request(:post, 'https://api.stripe.com/v1/customers')
      .to_return(
        status: 200,
        body: customer.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    customer
  end

  def mock_stripe_payment_intent_creation(amount = 1000, currency = 'eur')
    payment_intent = {
      id: 'pi_test_123',
      object: 'payment_intent',
      amount: amount,
      currency: currency,
      status: 'succeeded',
      created: Time.current.to_i
    }
    
    stub_request(:post, 'https://api.stripe.com/v1/payment_intents')
      .to_return(
        status: 200,
        body: payment_intent.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    payment_intent
  end

  def mock_stripe_checkout_session_creation(session_id = 'cs_test_123')
    checkout_session = {
      id: session_id,
      object: 'checkout.session',
      url: "https://checkout.stripe.com/pay/#{session_id}",
      payment_status: 'paid',
      created: Time.current.to_i
    }
    
    stub_request(:post, 'https://api.stripe.com/v1/checkout/sessions')
      .to_return(
        status: 200,
        body: checkout_session.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    checkout_session
  end

  def mock_stripe_subscription_creation(subscription_id = 'sub_test_123', customer_id = 'cus_test_123')
    subscription = {
      id: subscription_id,
      object: 'subscription',
      customer: customer_id,
      status: 'active',
      current_period_end: 1.month.from_now.to_i,
      created: Time.current.to_i
    }
    
    stub_request(:post, 'https://api.stripe.com/v1/subscriptions')
      .to_return(
        status: 200,
        body: subscription.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    subscription
  end

  def mock_stripe_subscription_cancellation(subscription_id = 'sub_test_123')
    canceled_subscription = {
      id: subscription_id,
      object: 'subscription',
      status: 'canceled',
      canceled_at: Time.current.to_i
    }
    
    stub_request(:delete, "https://api.stripe.com/v1/subscriptions/#{subscription_id}")
      .to_return(
        status: 200,
        body: canceled_subscription.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    canceled_subscription
  end

  def mock_stripe_error(error_type = 'card_error', error_code = 'card_declined', status = 402)
    error_response = {
      error: {
        type: error_type,
        code: error_code,
        message: 'Your card was declined.'
      }
    }
    
    stub_request(:any, /api\.stripe\.com/)
      .to_return(
        status: status,
        body: error_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
    
    error_response
  end

  def create_stripe_webhook_event(event_type, data_object)
    {
      id: "evt_#{SecureRandom.hex(12)}",
      object: 'event',
      type: event_type,
      data: {
        object: data_object
      },
      created: Time.current.to_i
    }
  end

  def stripe_webhook_signature(payload, secret = 'whsec_test_123', timestamp = nil)
    timestamp ||= Time.current.to_i
    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest('sha256', secret, signed_payload)
    "t=#{timestamp},v1=#{signature}"
  end

  def assert_stripe_request_made(method, path, &block)
    assert_requested method, "https://api.stripe.com#{path}", &block
  end

  def refute_stripe_request_made(method, path)
    assert_not_requested method, "https://api.stripe.com#{path}"
  end
end
