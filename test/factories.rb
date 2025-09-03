# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    sequence(:nom) { |n| "Plan #{n}" }
    preu { 1000 }
    descripcio { 'Test plan description' }
    
    trait :basic do
      nom { 'Basic' }
      preu { 500 }
    end
    
    trait :premium do
      nom { 'Premium' }
      preu { 2000 }
    end
  end

  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    nom { Faker::Name.first_name }
    cognoms { Faker::Name.last_name }
    data_naixement { Faker::Date.birthday(min_age: 18, max_age: 65) }
    sequence(:mobil) { |n| "12345678#{n}" }
    moto_marca { 'Honda' }
    moto_model { 'CBR' }
    presentacio { Faker::Lorem.paragraph }
    association :plan
    
    trait :with_avatar do
      after(:build) do |user|
        user.avatar.attach(
          io: StringIO.new('fake image data'),
          filename: 'avatar.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    
    trait :with_stripe_customer do
      stripe_customer_id { 'cus_test_123' }
    end
  end

  factory :sortide do
    title { Faker::Lorem.sentence }
    descripcio { Faker::Lorem.paragraph(sentence_count: 5) }
    start_date { 1.week.from_now.to_date }
    start_time { '09:00' }
    start_point { Faker::Address.full_address }
    latitut { Faker::Address.latitude }
    longitut { Faker::Address.longitude }
    preu { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    approved { true }
    
    trait :with_image do
      after(:build) do |sortide|
        sortide.ruta_foto.attach(
          io: StringIO.new('fake image data'),
          filename: 'route.jpg',
          content_type: 'image/jpeg'
        )
      end
    end
    
    trait :with_gpx do
      after(:build) do |sortide|
        gpx_content = <<~GPX
          <?xml version="1.0" encoding="UTF-8"?>
          <gpx version="1.1" creator="test">
            <trk>
              <name>Test Route</name>
              <trkseg>
                <trkpt lat="41.3851" lon="2.1734">
                  <ele>12</ele>
                </trkpt>
              </trkseg>
            </trk>
          </gpx>
        GPX
        
        sortide.ruta_gpx.attach(
          io: StringIO.new(gpx_content),
          filename: 'route.gpx',
          content_type: 'application/gpx+xml'
        )
      end
    end
  end

  factory :inscripcio do
    association :user
    association :sortide
    data_inscripcio { Time.current }
    
    trait :paid do
      stripe_payment_intent_id { 'pi_test_123' }
    end
  end

  factory :piulade do
    body { Faker::Lorem.paragraph }
    association :user
    
    trait :with_images do
      after(:build) do |piulade|
        2.times do |i|
          piulade.files.attach(
            io: StringIO.new('fake image data'),
            filename: "image#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end
      end
    end
  end

  factory :product do
    nom { Faker::Commerce.product_name }
    preu { Faker::Commerce.price }
    description { Faker::Lorem.paragraph }
    association :category
    
    trait :with_images do
      after(:build) do |product|
        3.times do |i|
          product.images.attach(
            io: StringIO.new('fake image data'),
            filename: "product#{i}.jpg",
            content_type: 'image/jpeg'
          )
        end
      end
    end
  end

  factory :category do
    nom { Faker::Commerce.department }
    descripcio { Faker::Lorem.sentence }
  end

  factory :image do
    association :sortide
    
    after(:build) do |image|
      image.file.attach(
        io: StringIO.new('fake image data'),
        filename: 'sortide_image.jpg',
        content_type: 'image/jpeg'
      )
    end
  end

  factory :cart do
    association :user
  end

  factory :cart_item do
    association :cart
    association :product
    quantity { 1 }
  end

  factory :purchase do
    association :user
    association :product
    preu { product.preu }
    stripe_payment_intent_id { 'pi_test_123' }
  end

  # Stripe-related factories for testing payment flows
  factory :stripe_checkout_session, class: Hash do
    skip_create
    
    initialize_with do
      {
        id: 'cs_test_123',
        object: 'checkout.session',
        payment_status: 'paid',
        customer: 'cus_test_123',
        metadata: {
          user_id: '1',
          sortide_id: '1'
        },
        line_items: {
          data: [
            {
              price: {
                id: 'price_test_123',
                unit_amount: 1000
              },
              quantity: 1
            }
          ]
        }
      }
    end
    
    trait :unpaid do
      payment_status { 'unpaid' }
    end
    
    trait :subscription do
      mode { 'subscription' }
      subscription { 'sub_test_123' }
    end
  end

  factory :stripe_payment_intent, class: Hash do
    skip_create
    
    initialize_with do
      {
        id: 'pi_test_123',
        object: 'payment_intent',
        status: 'succeeded',
        amount: 1000,
        currency: 'eur',
        customer: 'cus_test_123',
        metadata: {
          user_id: '1',
          sortide_id: '1'
        }
      }
    end
    
    trait :failed do
      status { 'payment_failed' }
    end
  end

  factory :stripe_customer, class: Hash do
    skip_create
    
    initialize_with do
      {
        id: 'cus_test_123',
        object: 'customer',
        email: 'test@example.com',
        subscriptions: {
          data: []
        }
      }
    end
    
    trait :with_subscription do
      subscriptions do
        {
          data: [
            {
              id: 'sub_test_123',
              status: 'active',
              current_period_end: 1.month.from_now.to_i
            }
          ]
        }
      end
    end
  end

  factory :stripe_subscription, class: Hash do
    skip_create
    
    initialize_with do
      {
        id: 'sub_test_123',
        object: 'subscription',
        status: 'active',
        customer: 'cus_test_123',
        current_period_end: 1.month.from_now.to_i,
        items: {
          data: [
            {
              price: {
                id: 'price_test_123',
                unit_amount: 1000
              }
            }
          ]
        }
      }
    end
    
    trait :canceled do
      status { 'canceled' }
    end
    
    trait :past_due do
      status { 'past_due' }
    end
  end
end
