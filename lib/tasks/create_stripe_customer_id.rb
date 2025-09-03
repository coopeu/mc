# frozen_string_literal: true

# Load the Rails environment
require_relative '../../config/environment'

def create_stripe_customer_for_user(user)
  customer = Stripe::Customer.create(
    email: user.email,
    name: user.nom
  )
  user.update_columns(
    stripe_customer_id: customer.id,
    stripe_email: customer.email
  )
  puts "Created Stripe customer for user #{user.id} with Stripe customer ID: #{customer.id}"
rescue StandardError => e
  puts "Failed to create Stripe customer for user #{user.id}: #{e.message}"
end

User.where(stripe_customer_id: nil).find_each do |user|
  create_stripe_customer_for_user(user)
end
