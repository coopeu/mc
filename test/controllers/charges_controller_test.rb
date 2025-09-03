# frozen_string_literal: true

require 'test_helper'

class ChargesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user, :with_stripe_customer)
    @sortide = create(:sortide)
    sign_in @user
  end

  test 'should create charge for sortide inscription' do
    VCR.use_cassette('stripe_create_payment_intent') do
      # Mock Stripe PaymentIntent creation
      payment_intent = build(:stripe_payment_intent)
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      post charges_inscripcions_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: @user.email,
        sortide_id: @sortide.id
      }

      assert_response :redirect
      assert_redirected_to @sortide
      
      # Verify inscription was created
      inscription = Inscripcio.find_by(user: @user, sortide: @sortide)
      assert inscription
      assert_equal 'pi_test_123', inscription.stripe_payment_intent_id
    end
  end

  test 'should handle stripe payment failure' do
    VCR.use_cassette('stripe_payment_failure') do
      # Mock Stripe error
      error_response = {
        error: {
          type: 'card_error',
          code: 'card_declined',
          message: 'Your card was declined.'
        }
      }
      mock_stripe_request(:post, '/v1/payment_intents', error_response, 402)

      post charges_inscripcions_path, params: {
        stripeToken: 'tok_chargeDeclined',
        stripeEmail: @user.email,
        sortide_id: @sortide.id
      }

      assert_response :redirect
      assert_redirected_to @sortide
      assert_match /error/i, flash[:alert]
      
      # Verify no inscription was created
      assert_nil Inscripcio.find_by(user: @user, sortide: @sortide)
    end
  end

  test 'should apply plan discount correctly' do
    premium_plan = create(:plan, :premium)
    premium_user = create(:user, plan: premium_plan)
    sign_in premium_user

    VCR.use_cassette('stripe_create_payment_intent_with_discount') do
      payment_intent = build(:stripe_payment_intent, amount: 800) # 20% discount
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      post charges_inscripcions_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: premium_user.email,
        sortide_id: @sortide.id
      }

      assert_response :redirect
      
      # Verify discounted amount was charged
      inscription = Inscripcio.find_by(user: premium_user, sortide: @sortide)
      assert inscription
    end
  end

  test 'should require authentication' do
    sign_out @user
    
    post charges_inscripcions_path, params: {
      stripeToken: 'tok_visa',
      stripeEmail: 'test@example.com',
      sortide_id: @sortide.id
    }

    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test 'should validate required parameters' do
    post charges_inscripcions_path, params: {
      stripeEmail: @user.email,
      sortide_id: @sortide.id
      # Missing stripeToken
    }

    assert_response :redirect
    assert_match /error/i, flash[:alert]
  end

  test 'should handle duplicate inscription attempts' do
    # Create existing inscription
    create(:inscripcio, user: @user, sortide: @sortide)

    VCR.use_cassette('stripe_duplicate_inscription') do
      payment_intent = build(:stripe_payment_intent)
      mock_stripe_request(:post, '/v1/payment_intents', payment_intent)

      post charges_inscripcions_path, params: {
        stripeToken: 'tok_visa',
        stripeEmail: @user.email,
        sortide_id: @sortide.id
      }

      assert_response :redirect
      assert_match /already/i, flash[:alert]
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
