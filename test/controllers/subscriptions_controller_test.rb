# frozen_string_literal: true

require 'test_helper'

class SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :with_stripe_customer)
    @plan = create(:plan, :premium)
    sign_in @user
  end

  test 'should create subscription checkout session' do
    VCR.use_cassette('stripe_create_subscription_session') do
      checkout_session = {
        id: 'cs_subscription_123',
        url: 'https://checkout.stripe.com/pay/cs_subscription_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      assert_redirected_to 'https://checkout.stripe.com/pay/cs_subscription_123'
    end
  end

  test 'should handle subscription creation with existing customer' do
    VCR.use_cassette('stripe_subscription_existing_customer') do
      checkout_session = {
        id: 'cs_subscription_456',
        url: 'https://checkout.stripe.com/pay/cs_subscription_456'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      
      # Verify the request included the existing customer
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions' do |req|
        body = URI.decode_www_form(req.body).to_h
        body['customer'] == @user.stripe_customer_id
      end
    end
  end

  test 'should create customer if not exists during subscription' do
    user_without_stripe = create(:user)
    sign_in user_without_stripe

    VCR.use_cassette('stripe_subscription_new_customer') do
      checkout_session = {
        id: 'cs_subscription_789',
        url: 'https://checkout.stripe.com/pay/cs_subscription_789'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      
      # Verify the request included customer creation data
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions' do |req|
        body = URI.decode_www_form(req.body).to_h
        body['customer_email'] == user_without_stripe.email
      end
    end
  end

  test 'should cancel existing subscription' do
    @user.update!(stripe_subscription_id: 'sub_test_123', subscription_status: 'active')

    VCR.use_cassette('stripe_cancel_subscription') do
      canceled_subscription = build(:stripe_subscription, :canceled)
      mock_stripe_request(:delete, '/v1/subscriptions/sub_test_123', canceled_subscription)

      delete subscription_path(@user.stripe_subscription_id)

      assert_response :redirect
      assert_redirected_to user_path(@user)
      assert_match /canceled/i, flash[:notice]
    end
  end

  test 'should handle subscription cancellation errors' do
    @user.update!(stripe_subscription_id: 'sub_test_123', subscription_status: 'active')

    VCR.use_cassette('stripe_cancel_subscription_error') do
      error_response = {
        error: {
          type: 'invalid_request_error',
          message: 'No such subscription: sub_test_123'
        }
      }
      mock_stripe_request(:delete, '/v1/subscriptions/sub_test_123', error_response, 404)

      delete subscription_path(@user.stripe_subscription_id)

      assert_response :redirect
      assert_redirected_to user_path(@user)
      assert_match /error/i, flash[:alert]
    end
  end

  test 'should update subscription plan' do
    @user.update!(stripe_subscription_id: 'sub_test_123', subscription_status: 'active')
    new_plan = create(:plan, :basic)

    VCR.use_cassette('stripe_update_subscription') do
      updated_subscription = build(:stripe_subscription)
      mock_stripe_request(:post, '/v1/subscriptions/sub_test_123', updated_subscription)

      patch subscription_path(@user.stripe_subscription_id), params: {
        plan_id: new_plan.id
      }

      assert_response :redirect
      assert_redirected_to user_path(@user)
      assert_match /updated/i, flash[:notice]
    end
  end

  test 'should require authentication for subscription actions' do
    sign_out @user

    post subscriptions_path, params: { plan_id: @plan.id }
    assert_response :redirect
    assert_redirected_to new_user_session_path

    delete subscription_path('sub_test_123')
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'should validate plan exists' do
    VCR.use_cassette('stripe_invalid_plan') do
      post subscriptions_path, params: {
        plan_id: 99999 # Non-existent plan
      }

      assert_response :redirect
      assert_match /not found/i, flash[:alert]
    end
  end

  test 'should handle stripe api errors gracefully' do
    VCR.use_cassette('stripe_api_error') do
      error_response = {
        error: {
          type: 'api_error',
          message: 'We are experiencing technical difficulties.'
        }
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', error_response, 500)

      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      assert_match /technical difficulties/i, flash[:alert]
    end
  end

  test 'should prevent duplicate active subscriptions' do
    @user.update!(stripe_subscription_id: 'sub_active_123', subscription_status: 'active')

    VCR.use_cassette('stripe_duplicate_subscription') do
      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      assert_match /already have an active subscription/i, flash[:alert]
    end
  end

  test 'should allow subscription after cancellation' do
    @user.update!(stripe_subscription_id: 'sub_canceled_123', subscription_status: 'canceled')

    VCR.use_cassette('stripe_resubscribe') do
      checkout_session = {
        id: 'cs_resubscribe_123',
        url: 'https://checkout.stripe.com/pay/cs_resubscribe_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      post subscriptions_path, params: {
        plan_id: @plan.id
      }

      assert_response :redirect
      assert_redirected_to 'https://checkout.stripe.com/pay/cs_resubscribe_123'
    end
  end

  test 'should handle subscription with trial period' do
    trial_plan = create(:plan, nom: 'Trial Plan', preu: 0)

    VCR.use_cassette('stripe_subscription_with_trial') do
      checkout_session = {
        id: 'cs_trial_123',
        url: 'https://checkout.stripe.com/pay/cs_trial_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      post subscriptions_path, params: {
        plan_id: trial_plan.id,
        trial_days: 14
      }

      assert_response :redirect
      
      # Verify trial period was included in the request
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions' do |req|
        body = URI.decode_www_form(req.body).to_h
        body['subscription_data[trial_period_days]'] == '14'
      end
    end
  end

  private

  def sign_in(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: user.password
      }
    }
  end

  def sign_out(user)
    delete destroy_user_session_path
  end
end
