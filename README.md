# 🏍️ motos.cat - Motorcycle Social Network Platform

[![Ruby](https://img.shields.io/badge/Ruby-3.4.3-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-green.svg)](#)
[![Stripe](https://img.shields.io/badge/Payments-Stripe-blue.svg)](https://stripe.com)
[![Tailwind CSS](https://img.shields.io/badge/CSS-Tailwind%204.0-38B2AC.svg)](https://tailwindcss.com)

A comprehensive motorcycle social networking platform built with Ruby on Rails 8, featuring ride organization, social interactions, e-commerce, and subscription management. Designed for the motorcycle community in Catalunya with full Catalan and English language support.

**Live Site:** [motos.cat](https://motos.cat)

## 🌟 Features

### 🏗️ Core Platform Features
- **User Authentication & Profiles** - Secure registration with Devise, comprehensive user profiles with coordinates
- **Ride Organization (Sortides)** - Create, manage, and join motorcycle rides with GPS integration and payment system
- **Social Network (Piulades)** - Share posts, photos, like and comment system with real-time updates
- **E-commerce Integration** - Product catalog with shopping cart and secure Stripe payments
- **Subscription Management** - Multiple membership tiers with automated Stripe billing
- **Admin Dashboard** - Comprehensive analytics, payment tracking, and user management
- **Scoring System (Puntuació)** - Gamified point system with weekly calculations and leaderboards

### 🎯 Social Features
- **Posts (Piulades)** - Rich text posts with image attachments and file validation
- **Social Interactions** - Polymorphic like system, nested comments, follow/unfollow
- **User Profiles** - Detailed rider profiles with motorcycle info and activity history
- **Community Feed** - Real-time activity stream with Turbo updates
- **Notification System** - Email notifications for all platform activities

### 🚴 Ride Management
- **Event Creation** - Full ride lifecycle management with GPS coordinates
- **Payment Integration** - Optional ride fees with Stripe checkout (€1 base + dynamic pricing)
- **Registration System** - Join rides with payment processing and email confirmations
- **Geographic Integration** - Municipality geocoding and rider position tracking
- **Route Planning** - GPX file support and coordinate validation

### 💳 E-commerce & Payments
- **Product Catalog** - Motorcycle gear and accessories with image processing
- **Shopping Cart** - Session-based cart with Stripe checkout integration
- **Donation System** - One-time donations (€5, €10, €25, €50, €100) with email receipts
- **Subscription Plans** - Premium and VIP tiers with automated billing
- **Webhook Processing** - Real-time Stripe event handling for all payment flows
- **Email Confirmations** - Automated emails for users and admins on all transactions

### 🔒 Security & Quality
- **Advanced File Validation** - FileValidatable concern with MIME detection and malicious content scanning
- **Image Processing** - Automatic resizing, optimization, and dimension validation with ImageMagick
- **Security Scanning** - Brakeman integration for vulnerability detection
- **Input Sanitization** - XSS prevention, CSRF protection, and secure headers
- **Comprehensive Testing** - 150+ tests covering all payment flows and security features

## 🚀 Quick Start

### Prerequisites

- **Ruby** 3.4.3 (managed with RVM)
- **Rails** 8.0+
- **Database** MySQL/MariaDB 10.5+
- **Node.js** 18+ with npm
- **Redis** 6+ (for background jobs and caching)
- **ImageMagick** (for image processing)

### System Requirements

- **Development**: Linux (Debian/Ubuntu recommended), macOS, or Windows with WSL2
- **Production**: Debian 12 server with Apache + Passenger
- **Memory**: 4GB+ RAM for development, 8GB+ for production
- **Storage**: 20GB+ available space

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/coopeu/MotosCat.git mc
   cd mc
   ```

2. **Install dependencies**
   ```bash
   bundle install
   npm install
   ```

3. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configure Rails credentials (secure method)**
   ```bash
   EDITOR=nano rails credentials:edit
   ```
   
   Add your configuration:
   ```yaml
   stripe:
     publishable_key: pk_test_...
     secret_key: sk_test_...
     webhook_secret: whsec_...
   
   recaptcha:
     site_key: your_recaptcha_site_key
     secret_key: your_recaptcha_secret_key
   
   # Database credentials (production only)
   username: motos_cat_user
   password: secure_password_here
   ```

5. **Start the development server**
   ```bash
   # Start Rails application
   rails server
   
   # In another terminal, start Redis (if not running)
   redis-server
   
   # In another terminal, start background jobs
   bundle exec sidekiq
   ```

6. **Verify installation**
   ```bash
   # Check database connection
   rails runner "puts 'Database: ' + (ActiveRecord::Base.connection.active? ? 'OK' : 'FAILED')"
   
   # Check Redis connection
   rails runner "puts 'Redis: ' + (Redis.new.ping == 'PONG' ? 'OK' : 'FAILED')"
   
   # Check Stripe configuration
   rails runner "puts 'Stripe: ' + (Stripe.api_key.present? ? 'OK' : 'MISSING API KEY')"
   ```

Visit `http://localhost:3000` to access the application.

### 🔑 Initial Setup

After installation:
1. **Create admin account**: `rails runner "User.create!(email: 'admin@motos.cat', password: 'password123', admin: true)"`
2. **Configure Stripe webhooks** in your Stripe dashboard pointing to `/webhook/stripe`
3. **Set up required directories**: Ensure `storage/` exists with proper permissions

## 🛠️ Development

### Development Commands

```bash
# Development server with live reloading
rails server                          # Start Rails on port 3000
bundle exec sidekiq                   # Background job processor
redis-server                          # Cache and job queue

# Asset compilation
npm run build                         # Development build
npm run build:prod                    # Production build with optimization
npm run build:css                     # Tailwind CSS compilation

# Database operations
rails db:migrate                      # Run pending migrations
rails db:seed                         # Load seed data
rails db:reset                        # Reset and reseed database
```

### Code Quality & Linting

```bash
# Ruby code style and security
bundle exec rubocop                    # Check style issues
bundle exec rubocop -a                 # Auto-fix safe issues
bundle exec brakeman                   # Security vulnerability scan

# JavaScript/TypeScript linting
npm run lint                           # ESLint checking
npm run lint:check                     # Check without fixing
npm run format                         # Prettier formatting
npm run type-check                     # TypeScript validation

# Full validation
npm run validate                       # All checks
npm run validate:full                  # All checks + performance analysis
```

### Testing

```bash
# Run comprehensive test suites
rails test                            # All tests
rails test:models                     # Model unit tests
rails test:controllers                # Controller integration tests
rails test:system                     # End-to-end system tests

# Specialized test suites
rails test:stripe                     # Stripe payment integration tests
rails test:security                   # Security-focused tests
rails test:comprehensive              # Full suite with coverage report

# JavaScript testing
npm test                              # Jest test suite
npm run test:watch                    # Watch mode
npm run test:coverage                 # Coverage reporting

# Performance testing
npm run analyze                       # Bundle size analysis
npm run analyze:full                  # Full performance analysis
```

## 📊 Project Structure

```
motos.cat/
├── 📂 app/
│   ├── 📂 controllers/              # 25+ REST controllers
│   │   ├── 📂 admin/               # Admin dashboard controllers
│   │   ├── charges_sortides_controller.rb  # Ride payment processing
│   │   ├── charges_donations_controller.rb # Donation processing
│   │   ├── subscriptions_controller.rb     # Subscription management
│   │   └── webhooks_controller.rb          # Stripe webhook handling
│   │
│   ├── 📂 models/                   # 30+ ActiveRecord models
│   │   ├── 📂 concerns/            # Shared functionality (FileValidatable, Likeable)
│   │   ├── user.rb                 # Central user model with Devise
│   │   ├── sortide.rb             # Ride events with GPS integration
│   │   ├── piulade.rb             # Social posts with rich content
│   │   ├── stripe_donation.rb     # Donation tracking
│   │   └── puntuacio.rb           # User scoring system
│   │
│   ├── 📂 services/                # Business logic services
│   │   ├── stripe_service.rb      # Complete Stripe integration
│   │   ├── rider_position_service.rb # GPS and geocoding
│   │   └── analytics_service.rb    # Performance tracking
│   │
│   ├── 📂 jobs/                    # Background processing
│   │   ├── puntuacio_setmanal_job.rb # Weekly scoring calculations
│   │   └── daily_admin_summary_job.rb # Admin reporting
│   │
│   ├── 📂 mailers/                 # Email notification system
│   │   ├── user_mailer.rb         # User notifications
│   │   └── admin_mailer.rb        # Admin notifications
│   │
│   └── 📂 javascript/              # Frontend TypeScript/React
│       ├── 📂 components/         # React components with shadcn/ui
│       ├── 📂 contexts/           # React context providers
│       └── 📂 controllers/        # Stimulus controllers
│
├── 📂 config/                      # Application configuration
│   ├── routes.rb                  # 100+ defined routes
│   ├── database.yml              # Database configuration
│   ├── credentials.yml.enc       # Encrypted secrets (Stripe, SMTP, etc.)
│   └── 📂 initializers/          # Rails configuration
│
├── 📂 test/                       # Comprehensive test suite (150+ tests)
│   ├── 📂 controllers/           # Integration tests
│   ├── 📂 models/               # Unit tests
│   ├── 📂 system/               # End-to-end tests
│   ├── 📂 integration/          # Payment flow tests
│   └── 📂 support/              # Test helpers
│
├── 📂 scripts/                    # Development and deployment automation
└── 📂 docs/                      # Project documentation
```

## 🔧 Configuration

### Rails Credentials (Encrypted)

**Production credentials** are stored securely in `config/credentials.yml.enc`:

```bash
# Edit production credentials
EDITOR=nano RAILS_ENV=production rails credentials:edit
```

Required structure:
```yaml
# Stripe payment processing (REQUIRED)
stripe:
  publishable_key: pk_live_...        # From Stripe Dashboard
  secret_key: sk_live_...             # From Stripe Dashboard  
  webhook_secret: whsec_...           # Webhook endpoint secret

# Database credentials (production)
username: motos_cat_user
password: secure_database_password

# SMTP email configuration
SMTP_USERNAME: notifications@motos.cat
SMTP_PASSWORD: smtp_password_here

# Security (auto-generated)
secret_key_base: (generated_automatically)

# Optional: External services
recaptcha:
  site_key: your_recaptcha_site_key
  secret_key: your_recaptcha_secret_key

redis_url: redis://localhost:6379/0
```

### Development Environment

For development, you can use either credentials or environment variables:

```bash
# Option 1: Development credentials
EDITOR=nano rails credentials:edit

# Option 2: Environment variables (create .env file)
cat > .env << 'EOF'
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
DATABASE_URL=mysql2://root:password@localhost/motoscat_development
REDIS_URL=redis://localhost:6379/0
EOF
```

### Stripe Configuration

1. **Create Stripe Account** at [stripe.com](https://stripe.com)
2. **Get API Keys** from Stripe Dashboard → Developers → API keys
3. **Configure Webhooks**:
   - URL: `https://yourdomain.com/webhook/stripe`
   - Events: `checkout.session.completed`, `invoice.payment_succeeded`, `customer.subscription.updated`
   - Copy webhook secret to credentials

4. **Sync Products & Plans**:
   ```bash
   # Create subscription plans in Stripe Dashboard, then sync:
   rails runner "Plan.sync_with_stripe"
   ```

## 🚀 Deployment

### Current Production Environment

**Live Production** (motos.cat):
- **Hosting**: HOSTIKA.lt (Lithuania) - Debian 12
- **Stack**: Apache 2.4.62 + Passenger + Ruby 3.4.3 + Rails 8.0
- **Database**: MySQL/MariaDB
- **SSL**: Let's Encrypt with auto-renewal
- **Directory**: `/var/www/html/mc`

### Production Deployment Steps

1. **Server Preparation**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install dependencies
   sudo apt install -y ruby-dev nodejs npm mysql-server redis-server \
                       imagemagick apache2 libapache2-mod-passenger
   
   # Install RVM and Ruby 3.4.3
   curl -sSL https://get.rvm.io | bash
   rvm install 3.4.3
   rvm use 3.4.3 --default
   ```

2. **Application Setup**
   ```bash
   cd /var/www/html
   git clone https://github.com/coopeu/MotosCat.git mc
   cd mc
   
   # Install dependencies
   bundle install --deployment --without development test
   npm install --production
   
   # Setup database
   RAILS_ENV=production rails db:create db:migrate
   
   # Compile assets
   RAILS_ENV=production rails assets:precompile
   
   # Set permissions
   chown -R www-data:www-data .
   chmod 600 config/credentials.yml.enc
   ```

3. **Apache Configuration**
   ```apache
   # /etc/apache2/sites-available/motos.cat.conf
   <VirtualHost *:443>
       ServerName motos.cat
       DocumentRoot /var/www/html/mc/public
       
       PassengerRuby /home/user/.rvm/gems/ruby-3.4.3/wrappers/ruby
       PassengerAppEnv production
       PassengerMinInstances 2
       PassengerMaxPoolSize 6
       
       SSLEngine on
       SSLCertificateFile /etc/letsencrypt/live/motos.cat/fullchain.pem
       SSLCertificateKeyFile /etc/letsencrypt/live/motos.cat/privkey.pem
       
       # Security headers
       Header always set Strict-Transport-Security "max-age=63072000"
       Header always set X-Frame-Options DENY
       Header always set X-Content-Type-Options nosniff
   </VirtualHost>
   ```

4. **SSL Certificate**
   ```bash
   sudo apt install certbot python3-certbot-apache
   sudo certbot --apache -d motos.cat
   ```

5. **Background Jobs (Sidekiq)**
   ```bash
   # Create systemd service for Sidekiq
   sudo systemctl enable sidekiq-motoscat
   sudo systemctl start sidekiq-motoscat
   ```

### Health Checks

```bash
# Verify production deployment
RAILS_ENV=production rails runner "puts 'App: OK'"
RAILS_ENV=production rails runner "puts 'Users: ' + User.count.to_s"
curl -I https://motos.cat
```

## 🧪 Testing

### Test Suites Available

- **Unit Tests** - Model validations, business logic, scoring calculations
- **Integration Tests** - Controller endpoints, payment flows, email delivery
- **System Tests** - End-to-end user journeys with Capybara
- **Security Tests** - File upload validation, authentication, authorization
- **Payment Tests** - Complete Stripe integration with webhook testing
- **Performance Tests** - Load testing and performance benchmarks

### Test Commands

```bash
# Run all tests
rails test                          # Standard test suite
rails test:comprehensive            # Full suite with coverage

# Specialized test suites
rails test:stripe                   # Payment integration tests
rails test:security                 # Security validation tests
rails test:performance              # Performance benchmarks

# Coverage reporting
open coverage/index.html            # View detailed coverage report
```

### Testing Payment Flows

Use Stripe test mode with test data:
- **Test Card**: `4242424242424242`
- **Test Email**: Any valid email format
- **Webhook Testing**: Configure local webhook endpoint or use Stripe CLI

## 📚 Key Documentation

### Project Documentation
- **[CLAUDE.md](CLAUDE.md)** - AI assistant integration guide
- **[DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md)** - Detailed development environment setup
- **[PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)** - Production deployment guide
- **[DEPLOYMENT_PROTOCOL.md](DEPLOYMENT_PROTOCOL.md)** - Safe deployment procedures
- **[PUNTUACIO_IMPLEMENTATION_SUMMARY.md](PUNTUACIO_IMPLEMENTATION_SUMMARY.md)** - Scoring system details
- **[PERFORMANCE_OPTIMIZATION_STRATEGY.md](PERFORMANCE_OPTIMIZATION_STRATEGY.md)** - Performance optimization guide
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - REST API endpoint documentation

### Technical References
- **[docs/security-architecture.md](docs/security-architecture.md)** - Security implementation details
- **[PROJECT_INDEX.md](PROJECT_INDEX.md)** - Comprehensive project index
- **[MODELS_DOCUMENTATION.md](MODELS_DOCUMENTATION.md)** - Data model specifications

## 🔒 Security

### Implemented Security Measures

- **File Upload Security** - FileValidatable concern with comprehensive validation
- **Payment Security** - PCI-compliant Stripe integration with webhook validation
- **Authentication** - Devise with secure session management
- **Authorization** - Multi-level access control (admin, premium users)
- **Input Validation** - XSS prevention, SQL injection protection
- **Security Headers** - HSTS, CSP, X-Frame-Options, X-Content-Type-Options
- **Regular Scanning** - Brakeman security analysis in development

### File Validation Features

```ruby
# app/models/concerns/file_validatable.rb
# Validates:
# - MIME type detection and validation
# - File extension verification
# - Image dimensions and file size limits
# - Malicious content scanning
# - Supported formats: JPEG, PNG, GIF, GPX
```

## 💳 Payment Integration Details

### Stripe Integration Features

- **Subscription Management**: Monthly/yearly plans with automated billing
- **One-time Donations**: Fixed amounts (€5, €10, €25, €50, €100)
- **Ride Payments**: Dynamic pricing for premium rides (€1 base fee)
- **E-commerce Checkout**: Product purchases with cart functionality
- **Webhook Processing**: Real-time event handling for all payment types
- **Email Notifications**: Automated receipts and confirmations

### Payment Flow Architecture

```ruby
# app/services/stripe_service.rb - Handles all Stripe operations
# app/controllers/webhooks_controller.rb - Processes Stripe events
# app/models/stripe_donation.rb - Tracks donation records
# app/mailers/user_mailer.rb - Payment confirmation emails
```

## 🌍 Internationalization

- **Primary Language**: Catalan (`:ca`)
- **Secondary Language**: English (`:en`)
- **Timezone**: Europe/Paris (CET/CEST for Catalunya)
- **Locale Files**: `config/locales/ca.yml`, `config/locales/en.yml`
- **Date Formats**: European format (DD/MM/YYYY)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add comprehensive tests
4. Run the full test suite: `rails test:comprehensive`
5. Check code quality: `bundle exec rubocop && npm run validate`
6. Commit with descriptive messages
7. Push to your fork and create a Pull Request

### Development Guidelines

- **Follow Rails conventions** - Use Rails patterns and naming conventions
- **Add tests** - All new features require corresponding tests
- **Security first** - Use FileValidatable for uploads, validate all inputs
- **Performance aware** - Consider database queries and asset sizes
- **Catalan naming** - Use Catalan terms for domain concepts (sortides, piulades)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Ruby on Rails** - Web application framework
- **Stripe** - Payment processing platform  
- **Tailwind CSS** - Utility-first CSS framework
- **Stimulus & Turbo** - JavaScript framework for Rails
- **Devise** - Authentication solution
- **shadcn/ui** - Modern UI component library
- **ImageMagick** - Image processing
- **Sidekiq** - Background job processing

## 📞 Support

For support and questions:

- **Email**: coopeu@coopeu.com
- **Website**: [motos.cat](https://motos.cat)
- **Issues**: [GitHub Issues](https://github.com/coopeu/MotosCat/issues)

---

**Built with ❤️ for the motorcycle community in Catalunya**
