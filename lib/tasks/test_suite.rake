# frozen_string_literal: true

namespace :test do
  desc 'Run all Stripe payment flow tests'
  task stripe: :environment do
    puts '🔄 Running Stripe payment flow tests...'
    
    test_files = [
      'test/controllers/charges_controller_test.rb',
      'test/controllers/purchases_controller_test.rb',
      'test/controllers/subscriptions_controller_test.rb',
      'test/controllers/webhooks_controller_test.rb',
      'test/system/stripe_payment_flow_test.rb'
    ]
    
    system("rails test #{test_files.join(' ')}")
  end

  desc 'Run all file upload validation tests'
  task file_uploads: :environment do
    puts '📁 Running file upload validation tests...'
    
    test_files = [
      'test/models/user_test.rb',
      'test/models/sortide_test.rb',
      'test/models/concerns/file_validatable_test.rb'
    ]
    
    system("rails test #{test_files.join(' ')}")
  end

  desc 'Run all model validation tests'
  task models: :environment do
    puts '🏗️ Running model validation tests...'
    system('rails test test/models/')
  end

  desc 'Run all controller tests'
  task controllers: :environment do
    puts '🎮 Running controller tests...'
    system('rails test test/controllers/')
  end

  desc 'Run all system tests'
  task system: :environment do
    puts '🖥️ Running system tests...'
    system('rails test:system')
  end

  desc 'Run comprehensive test suite with coverage'
  task comprehensive: :environment do
    puts '🧪 Running comprehensive test suite...'
    
    # Set coverage environment
    ENV['COVERAGE'] = 'true'
    
    # Run all tests
    puts "\n1️⃣ Running unit tests..."
    system('rails test test/models/')
    
    puts "\n2️⃣ Running controller tests..."
    system('rails test test/controllers/')
    
    puts "\n3️⃣ Running integration tests..."
    system('rails test test/integration/')
    
    puts "\n4️⃣ Running system tests..."
    system('rails test:system')
    
    puts "\n📊 Test coverage report generated in coverage/"
    puts "Open coverage/index.html to view detailed coverage report"
  end

  desc 'Run security-focused tests'
  task security: :environment do
    puts '🔒 Running security-focused tests...'
    
    test_files = [
      'test/models/concerns/file_validatable_test.rb',
      'test/controllers/webhooks_controller_test.rb',
      'test/models/user_test.rb'
    ]
    
    system("rails test #{test_files.join(' ')}")
    
    puts "\n🔍 Running additional security checks..."
    system('bundle exec brakeman -q --no-pager')
  end

  desc 'Run performance tests'
  task performance: :environment do
    puts '⚡ Running performance tests...'
    
    # Run tests with performance profiling
    ENV['RAILS_ENV'] = 'test'
    
    require 'benchmark'
    
    puts "\nBenchmarking critical operations..."
    
    Benchmark.bm(30) do |x|
      x.report('User creation with validations:') do
        100.times do
          user = build(:user)
          user.valid?
        end
      end
      
      x.report('File validation (image):') do
        50.times do
          user = build(:user)
          user.avatar.attach(
            io: StringIO.new('fake image data'),
            filename: 'test.jpg',
            content_type: 'image/jpeg'
          )
          user.valid?
        end
      end
      
      x.report('Stripe webhook processing:') do
        25.times do
          payload = { type: 'test.event', data: { object: { id: 'test' } } }.to_json
          signature = OpenSSL::HMAC.hexdigest('sha256', 'test_secret', "#{Time.current.to_i}.#{payload}")
          # Simulate webhook processing
        end
      end
    end
  end

  desc 'Generate test data for manual testing'
  task seed_test_data: :environment do
    puts '🌱 Generating test data...'
    
    # Create test plans
    basic_plan = Plan.find_or_create_by(nom: 'Basic Test Plan') do |plan|
      plan.preu = 500
      plan.descripcio = 'Basic plan for testing'
    end
    
    premium_plan = Plan.find_or_create_by(nom: 'Premium Test Plan') do |plan|
      plan.preu = 1500
      plan.descripcio = 'Premium plan for testing'
    end
    
    # Create test users
    test_user = User.find_or_create_by(email: 'test@motos.cat') do |user|
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.nom = 'Test'
      user.cognoms = 'User'
      user.data_naixement = 30.years.ago
      user.mobil = '123456789'
      user.moto_marca = 'Honda'
      user.moto_model = 'CBR'
      user.presentacio = 'Test user for development'
      user.plan = basic_plan
    end
    
    admin_user = User.find_or_create_by(email: 'admin@motos.cat') do |user|
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.nom = 'Admin'
      user.cognoms = 'User'
      user.data_naixement = 35.years.ago
      user.mobil = '987654321'
      user.moto_marca = 'Yamaha'
      user.moto_model = 'R1'
      user.presentacio = 'Admin user for testing'
      user.plan = premium_plan
      user.admin = true
    end
    
    # Create test sortides
    3.times do |i|
      Sortide.find_or_create_by(title: "Test Route #{i + 1}") do |sortide|
        sortide.descripcio = "This is a test route #{i + 1} for development and testing purposes."
        sortide.start_date = (i + 1).weeks.from_now
        sortide.start_time = '09:00'
        sortide.start_point = "Test Starting Point #{i + 1}"
        sortide.preu = 25.0 + (i * 5)
        sortide.approved = true
        sortide.max_inscrits = 10
        sortide.min_inscrits = 3
        sortide.Km = 50 + (i * 10)
        sortide.num_dies = 1
        sortide.fi_ndies = 1
        sortide.oberta = true
      end
    end
    
    # Create test products
    3.times do |i|
      Product.find_or_create_by(nom: "Test Product #{i + 1}") do |product|
        product.preu = 15.0 + (i * 5)
        product.description = "This is a test product #{i + 1} for development purposes."
      end
    end
    
    puts "✅ Test data created successfully!"
    puts "Test user: test@motos.cat / password123"
    puts "Admin user: admin@motos.cat / password123"
  end

  desc 'Clean test data'
  task clean_test_data: :environment do
    puts '🧹 Cleaning test data...'
    
    # Only clean test data, not production data
    if Rails.env.test? || Rails.env.development?
      User.where(email: ['test@motos.cat', 'admin@motos.cat']).destroy_all
      Sortide.where('title LIKE ?', 'Test Route%').destroy_all
      Product.where('nom LIKE ?', 'Test Product%').destroy_all
      Plan.where('nom LIKE ?', '%Test Plan').destroy_all
      
      puts "✅ Test data cleaned successfully!"
    else
      puts "❌ Can only clean test data in test or development environment"
    end
  end
end

# Add coverage reporting task
namespace :coverage do
  desc 'Generate and open coverage report'
  task report: :environment do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test:comprehensive'].invoke
    
    if File.exist?('coverage/index.html')
      system('open coverage/index.html') if RUBY_PLATFORM.include?('darwin')
      puts "📊 Coverage report available at: coverage/index.html"
    else
      puts "❌ Coverage report not found. Make sure SimpleCov is configured correctly."
    end
  end
end
