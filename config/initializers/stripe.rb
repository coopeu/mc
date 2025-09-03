# require 'stripe'
# 
# Rails.configuration.stripe = {
#   publishable_key: Rails.application.credentials.dig(:stripe, :publishable_key),
#   secret_key: Rails.application.credentials.dig(:stripe, :secret_key),
#   signing_secret: Rails.application.credentials.dig(:stripe, :webhook_signing_secret)
# }
# 
# Stripe.api_key = Rails.configuration.stripe[:secret_key]
# 
# # Set API version to ensure consistent behavior
# Stripe.api_version = '2023-10-16'
# 
# # Configure webhook events
# StripeEvent.configure do |events|
#   events.subscribe 'charge.succeeded' do |event|
#     # Handle successful charge
#   end
# 
#   events.subscribe 'charge.failed' do |event|
#     # Handle failed charge
#   end
# 
#   events.subscribe 'payment_intent.succeeded' do |event|
#     # Handle successful payment intent
#   end
# 
#   events.subscribe 'payment_intent.payment_failed' do |event|
#     # Handle failed payment intent
#   end
# end
# 
# # Add error handling middleware
# Rails.application.config.middleware.use Stripe::ErrorHandler
# 
