# frozen_string_literal: true

namespace :stripe do
  desc 'Validate Plan.sku (or codi) against Stripe Price IDs'
  task validate_prices: :environment do
    if ENV['STRIPE_SECRET_KEY'].blank?
      puts 'ERROR: STRIPE_SECRET_KEY not set'
      exit 1
    end

    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY', nil)

    ok = true
    Plan.find_each do |plan|
      # Prefer sku; fallback to codi only if attribute exists on this model
      price_id = plan.respond_to?(:sku) && plan.sku.present? ? plan.sku : nil
      price_id = plan.codi.presence if price_id.blank? && plan.respond_to?(:codi)
      if price_id.blank?
        ok = false
        puts "[MISSING] Plan ##{plan.id} '#{plan.nom}' has no sku/codi"
        next
      end

      begin
        price = Stripe::Price.retrieve(price_id)
        amount_eur = (price.unit_amount || 0) / 100.0
        puts "[OK] Plan ##{plan.id} '#{plan.nom}' => Price #{price.id} (#{amount_eur} #{price.currency})"
      rescue Stripe::InvalidRequestError => e
        ok = false
        puts "[NOT FOUND] Plan ##{plan.id} '#{plan.nom}' => Price '#{price_id}' (#{e.message})"
      rescue StandardError => e
        ok = false
        puts "[ERROR] Plan ##{plan.id} '#{plan.nom}' => #{e.class}: #{e.message}"
      end
    end

    exit(ok ? 0 : 2)
  end
end
