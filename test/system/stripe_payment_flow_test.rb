# frozen_string_literal: true

require 'application_system_test_case'

class StripePaymentFlowTest < ApplicationSystemTestCase
  setup do
    @user = create(:user, :with_stripe_customer)
    @sortide = create(:sortide, preu: 25.0)
    @product = create(:product, preu: 15.0)
    
    # Mock Stripe responses
    WebMock.allow_net_connect!
  end

  teardown do
    WebMock.disable_net_connect!
  end

  test 'user can pay for sortide inscription' do
    VCR.use_cassette('system_sortide_payment') do
      # Mock Stripe checkout session creation
      checkout_session = {
        id: 'cs_test_123',
        url: 'https://checkout.stripe.com/pay/cs_test_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      sign_in @user
      visit sortide_path(@sortide)
      
      # Should see inscription form
      assert_text @sortide.title
      assert_text "#{@sortide.preu}€"
      
      # Click inscription button
      click_button 'Inscriu-te'
      
      # Should be redirected to Stripe checkout
      # In a real test, we'd mock the Stripe redirect
      # For now, we'll check that the request was made
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions'
    end
  end

  test 'user can purchase product' do
    VCR.use_cassette('system_product_purchase') do
      checkout_session = {
        id: 'cs_product_123',
        url: 'https://checkout.stripe.com/pay/cs_product_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      sign_in @user
      visit product_path(@product)
      
      # Should see product details
      assert_text @product.nom
      assert_text "#{@product.preu}€"
      
      # Add to cart
      click_button 'Afegir al carret'
      
      # Go to cart
      visit cart_path
      
      # Proceed to checkout
      click_button 'Pagar'
      
      # Should initiate Stripe checkout
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions'
    end
  end

  test 'user can subscribe to premium plan' do
    VCR.use_cassette('system_subscription') do
      premium_plan = create(:plan, :premium)
      
      checkout_session = {
        id: 'cs_subscription_123',
        url: 'https://checkout.stripe.com/pay/cs_subscription_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      sign_in @user
      visit plans_path
      
      # Should see available plans
      assert_text premium_plan.nom
      assert_text "#{premium_plan.preu / 100}€"
      
      # Click subscribe button
      within "[data-plan-id='#{premium_plan.id}']" do
        click_button 'Subscriu-te'
      end
      
      # Should initiate subscription checkout
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions' do |req|
        body = URI.decode_www_form(req.body).to_h
        body['mode'] == 'subscription'
      end
    end
  end

  test 'payment failure shows appropriate error' do
    VCR.use_cassette('system_payment_failure') do
      # Mock Stripe error
      error_response = {
        error: {
          type: 'card_error',
          code: 'card_declined',
          message: 'Your card was declined.'
        }
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', error_response, 402)

      sign_in @user
      visit sortide_path(@sortide)
      
      click_button 'Inscriu-te'
      
      # Should show error message
      assert_text 'Your card was declined'
      assert_current_path sortide_path(@sortide)
    end
  end

  test 'user cannot inscribe to full sortide' do
    # Fill up the sortide
    @sortide.update!(max_inscrits: 2)
    2.times { create(:inscripcio, sortide: @sortide) }
    
    sign_in @user
    visit sortide_path(@sortide)
    
    # Should not see inscription button
    assert_no_button 'Inscriu-te'
    assert_text 'Sortida completa'
  end

  test 'user cannot inscribe twice to same sortide' do
    # Create existing inscription
    create(:inscripcio, user: @user, sortide: @sortide)
    
    sign_in @user
    visit sortide_path(@sortide)
    
    # Should not see inscription button
    assert_no_button 'Inscriu-te'
    assert_text 'Ja estàs inscrit'
  end

  test 'unauthenticated user is redirected to login' do
    visit sortide_path(@sortide)
    
    # Should see login prompt instead of inscription button
    assert_no_button 'Inscriu-te'
    assert_link 'Inicia sessió'
    
    click_link 'Inicia sessió'
    assert_current_path new_user_session_path
  end

  test 'premium user gets discount on sortide' do
    VCR.use_cassette('system_premium_discount') do
      premium_plan = create(:plan, :premium)
      premium_user = create(:user, plan: premium_plan)
      
      # Assuming premium users get 20% discount
      discounted_price = @sortide.preu * 0.8
      
      checkout_session = {
        id: 'cs_discount_123',
        url: 'https://checkout.stripe.com/pay/cs_discount_123'
      }
      mock_stripe_request(:post, '/v1/checkout/sessions', checkout_session)

      sign_in premium_user
      visit sortide_path(@sortide)
      
      # Should show discounted price
      assert_text "#{discounted_price}€"
      assert_text 'Descompte Premium'
      
      click_button 'Inscriu-te'
      
      # Verify discounted amount in Stripe request
      assert_requested :post, 'https://api.stripe.com/v1/checkout/sessions' do |req|
        body = URI.decode_www_form(req.body).to_h
        body['line_items[0][price_data][unit_amount]'] == (discounted_price * 100).to_i.to_s
      end
    end
  end

  test 'cart shows correct totals' do
    sign_in @user
    
    # Add multiple products to cart
    product1 = create(:product, preu: 10.0)
    product2 = create(:product, preu: 15.0)
    
    visit product_path(product1)
    click_button 'Afegir al carret'
    
    visit product_path(product2)
    click_button 'Afegir al carret'
    
    visit cart_path
    
    # Should show both products and correct total
    assert_text product1.nom
    assert_text product2.nom
    assert_text '25.0€' # Total
  end

  test 'user can remove items from cart' do
    sign_in @user
    
    visit product_path(@product)
    click_button 'Afegir al carret'
    
    visit cart_path
    assert_text @product.nom
    
    # Remove item
    click_button 'Eliminar'
    
    # Cart should be empty
    assert_text 'El teu carret està buit'
    assert_no_text @product.nom
  end

  test 'subscription management works correctly' do
    VCR.use_cassette('system_subscription_management') do
      # User with active subscription
      @user.update!(
        stripe_subscription_id: 'sub_test_123',
        subscription_status: 'active'
      )
      
      # Mock subscription cancellation
      canceled_subscription = build(:stripe_subscription, :canceled)
      mock_stripe_request(:delete, '/v1/subscriptions/sub_test_123', canceled_subscription)

      sign_in @user
      visit user_path(@user)
      
      # Should show subscription status
      assert_text 'Subscripció activa'
      
      # Cancel subscription
      click_button 'Cancel·lar subscripció'
      
      # Should show cancellation confirmation
      assert_text 'Subscripció cancel·lada'
      
      # Verify API call was made
      assert_requested :delete, 'https://api.stripe.com/v1/subscriptions/sub_test_123'
    end
  end

  private

  def sign_in(user)
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def mock_stripe_request(method, path, response_body, status = 200)
    stub_request(method, "https://api.stripe.com#{path}")
      .to_return(
        status: status,
        body: response_body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
