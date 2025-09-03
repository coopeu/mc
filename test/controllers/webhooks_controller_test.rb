# frozen_string_literal: true

require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @secret = 'whsec_test_123'
    Rails.application.credentials.config[:stripe] = { webhook_secret: @secret }
    @user = create(:user, :with_stripe_customer)
    @sortide = create(:sortide)
  end

  test 'returns 400 when signature is invalid' do
    payload = { type: 'checkout.session.completed', data: { object: { id: 'cs_test' } } }.to_json
    headers = { 'Stripe-Signature' => 't=12345,v1=invalidsig' }

    post '/webhook/stripe', headers: headers.merge({ 'CONTENT_TYPE' => 'application/json' }), params: payload
    assert_response :bad_request
  end

  test 'returns 400 when signature is missing' do
    payload = { type: 'checkout.session.completed', data: { object: { id: 'cs_test' } } }.to_json

    post '/webhook/stripe', headers: { 'CONTENT_TYPE' => 'application/json' }, params: payload
    assert_response :bad_request
  end

  test 'handles checkout.session.completed for sortide inscription' do
    checkout_session = build(:stripe_checkout_session,
      metadata: {
        user_id: @user.id.to_s,
        sortide_id: @sortide.id.to_s,
        type: 'inscription'
      }
    )

    payload = {
      type: 'checkout.session.completed',
      data: { object: checkout_session }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_checkout_session_completed') do
      post '/webhook/stripe',
           headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
           params: payload

      assert_response :success

      # Verify inscription was created
      inscription = Inscripcio.find_by(user: @user, sortide: @sortide)
      assert inscription
      assert_equal 'cs_test_123', inscription.stripe_checkout_session_id
    end
  end

  test 'handles checkout.session.completed for product purchase' do
    product = create(:product)
    checkout_session = build(:stripe_checkout_session,
      metadata: {
        user_id: @user.id.to_s,
        product_id: product.id.to_s,
        type: 'purchase'
      }
    )

    payload = {
      type: 'checkout.session.completed',
      data: { object: checkout_session }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_product_purchase') do
      post '/webhook/stripe',
           headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
           params: payload

      assert_response :success

      # Verify purchase was created
      purchase = Purchase.find_by(user: @user, product: product)
      assert purchase
      assert_equal 'cs_test_123', purchase.stripe_checkout_session_id
    end
  end

  test 'handles customer.subscription.created' do
    subscription = build(:stripe_subscription, customer: @user.stripe_customer_id)

    payload = {
      type: 'customer.subscription.created',
      data: { object: subscription }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_subscription_created') do
      post '/webhook/stripe',
           headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
           params: payload

      assert_response :success

      # Verify user subscription status was updated
      @user.reload
      assert_equal 'sub_test_123', @user.stripe_subscription_id
      assert @user.subscription_active?
    end
  end

  test 'handles customer.subscription.deleted' do
    @user.update!(stripe_subscription_id: 'sub_test_123', subscription_status: 'active')

    subscription = build(:stripe_subscription, :canceled, customer: @user.stripe_customer_id)

    payload = {
      type: 'customer.subscription.deleted',
      data: { object: subscription }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_subscription_deleted') do
      post '/webhook/stripe',
           headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
           params: payload

      assert_response :success

      # Verify user subscription was canceled
      @user.reload
      assert_equal 'canceled', @user.subscription_status
      assert_not @user.subscription_active?
    end
  end

  test 'handles payment_intent.payment_failed' do
    payment_intent = build(:stripe_payment_intent, :failed,
      metadata: {
        user_id: @user.id.to_s,
        sortide_id: @sortide.id.to_s
      }
    )

    payload = {
      type: 'payment_intent.payment_failed',
      data: { object: payment_intent }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_payment_failed') do
      post '/webhook/stripe',
           headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
           params: payload

      assert_response :success

      # Verify failed payment was logged
      # This would typically send an email or create a notification
    end
  end

  test 'handles unknown webhook events gracefully' do
    payload = {
      type: 'unknown.event.type',
      data: { object: { id: 'unknown_123' } }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    post '/webhook/stripe',
         headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
         params: payload

    assert_response :success
  end

  test 'handles malformed JSON payload' do
    payload = 'invalid json'
    signature = stripe_webhook_signature(payload, @secret)

    post '/webhook/stripe',
         headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
         params: payload

    assert_response :bad_request
  end

  test 'handles missing metadata gracefully' do
    checkout_session = build(:stripe_checkout_session, metadata: {})

    payload = {
      type: 'checkout.session.completed',
      data: { object: checkout_session }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    post '/webhook/stripe',
         headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
         params: payload

    assert_response :success
    # Should not create any records without proper metadata
  end

  test 'handles duplicate webhook events' do
    checkout_session = build(:stripe_checkout_session,
      metadata: {
        user_id: @user.id.to_s,
        sortide_id: @sortide.id.to_s,
        type: 'inscription'
      }
    )

    payload = {
      type: 'checkout.session.completed',
      data: { object: checkout_session }
    }.to_json

    signature = stripe_webhook_signature(payload, @secret)

    VCR.use_cassette('webhook_duplicate_events') do
      # Send the same webhook twice
      2.times do
        post '/webhook/stripe',
             headers: { 'Stripe-Signature' => signature, 'CONTENT_TYPE' => 'application/json' },
             params: payload

        assert_response :success
      end

      # Should only create one inscription
      inscriptions = Inscripcio.where(user: @user, sortide: @sortide)
      assert_equal 1, inscriptions.count
    end
  end

  test 'validates timestamp to prevent replay attacks' do
    old_timestamp = 10.minutes.ago.to_i
    payload = { type: 'checkout.session.completed', data: { object: { id: 'cs_test' } } }.to_json

    signed_payload = "#{old_timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest('sha256', @secret, signed_payload)
    sig_header = "t=#{old_timestamp},v1=#{signature}"

    post '/webhook/stripe',
         headers: { 'Stripe-Signature' => sig_header, 'CONTENT_TYPE' => 'application/json' },
         params: payload

    assert_response :bad_request
  end
end
