# frozen_string_literal: true

require 'test_helper'

class PurchasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :with_stripe_customer)
    @product = create(:product)
    sign_in @user
  end

  test 'should create purchase with stripe payment' do
    VCR.use_cassette('stripe_create_purchase_payment') do
      payment_intent = build(:stripe_payment_intent, amount: (@product.preu * 100).to_i)
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      post purchases_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: @user.email,
        product_id: @product.id
      }

      assert_response :redirect
      assert_redirected_to @product
      
      # Verify purchase was created
      purchase = Purchase.find_by(user: @user, product: @product)
      assert purchase
      assert_equal 'pi_test_123', purchase.stripe_payment_intent_id
      assert_equal @product.preu, purchase.preu
    end
  end

  test 'should handle insufficient funds error' do
    VCR.use_cassette('stripe_insufficient_funds') do
      error_response = {
        error: {
          type: 'card_error',
          code: 'insufficient_funds',
          message: 'Your card has insufficient funds.'
        }
      }
      mock_stripe_request(:post, '/v1/payment_intents', error_response, 402)

      post purchases_path, params: {
        stripeToken: 'tok_chargeDeclined',
        stripeEmail: @user.email,
        product_id: @product.id
      }

      assert_response :redirect
      assert_redirected_to @product
      assert_match /insufficient funds/i, flash[:alert]
      
      # Verify no purchase was created
      assert_nil Purchase.find_by(user: @user, product: @product)
    end
  end

  test 'should handle network errors gracefully' do
    VCR.use_cassette('stripe_network_error') do
      # Mock network timeout
      stub_request(:post, 'https://api.stripe.com/v1/payment_intents')
        .to_timeout

      post purchases_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: @user.email,
        product_id: @product.id
      }

      assert_response :redirect
      assert_redirected_to @product
      assert_match /network error/i, flash[:alert]
    end
  end

  test 'should validate product exists' do
    VCR.use_cassette('stripe_invalid_product') do
      post purchases_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: @user.email,
        product_id: 99999 # Non-existent product
      }

      assert_response :redirect
      assert_match /not found/i, flash[:alert]
    end
  end

  test 'should require authentication for purchases' do
    sign_out @user
    
    post purchases_path, params: {
      stripeToken: 'tok_visa',
      stripeEmail: 'test@example.com',
      product_id: @product.id
    }

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'should create stripe customer if not exists' do
    user_without_stripe = create(:user)
    sign_in user_without_stripe

    VCR.use_cassette('stripe_create_customer_and_purchase') do
      # Mock customer creation
      customer = build(:stripe_customer, email: user_without_stripe.email)
      mock_stripe_request(:post, '/v1/customers', customer)
      
      # Mock payment intent creation
      payment_intent = build(:stripe_payment_intent, customer: 'cus_test_123')
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      post purchases_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: user_without_stripe.email,
        product_id: @product.id
      }

      assert_response :redirect
      
      # Verify user now has stripe customer ID
      user_without_stripe.reload
      assert_equal 'cus_test_123', user_without_stripe.stripe_customer_id
    end
  end

  test 'should handle multiple concurrent purchases' do
    VCR.use_cassette('stripe_concurrent_purchases') do
      payment_intent = build(:stripe_payment_intent)
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      # Simulate concurrent requests
      threads = []
      3.times do
        threads << Thread.new do
          post purchases_path, params: {
            stripeToken: 'tok_visa',
            stripeEmail: @user.email,
            product_id: @product.id
          }
        end
      end
      
      threads.each(&:join)
      
      # Should only create one purchase due to database constraints
      purchases = Purchase.where(user: @user, product: @product)
      assert_equal 1, purchases.count
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
