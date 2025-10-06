# 🏍️ MotosCat Development Environment

[![Ruby](https://img.shields.io/badge/Ruby-3.4.3-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Live](https://img.shields.io/badge/Live-motos.cat-success.svg)](https://motos.cat)
[![Tailwind CSS](https://img.shields.io/badge/CSS-Tailwind%204.0-38B2AC.svg)](https://tailwindcss.com)
[![Stripe](https://img.shields.io/badge/Payments-Stripe-blue.svg)](https://stripe.com)

**MotosCat** is a comprehensive motorcycle social networking platform built with Ruby on Rails 8, designed specifically for the Catalan motorcycle community. This repository contains the development environment for the live production site at [motos.cat](https://motos.cat).

🌐 **Live Site**: [https://motos.cat](https://motos.cat)
📦 **Repository**: Development environment on Debian/RVM

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Development](#-development)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

MotosCat combines social networking, ride organization, e-commerce, and subscription management into a single comprehensive platform for motorcycle enthusiasts in Catalunya. Built with modern Ruby on Rails 8 and featuring full bilingual support (Catalan/English).

### Platform Highlights

- **Production-Ready**: Live at motos.cat serving the Catalan motorcycle community
- **Modern Stack**: Rails 8.0, Ruby 3.4.3, MySQL, Redis, Tailwind CSS 4.0
- **Payment Processing**: Full Stripe integration with subscriptions and webhooks
- **Multilingual**: Complete Catalan and English translations
- **Responsive Design**: Mobile-first Tailwind CSS with modern UI components
- **Background Jobs**: Sidekiq for async processing and scheduled tasks

---

## ✨ Features

### 🔐 User Management & Authentication
- **Secure Authentication**: Devise-based with encrypted sessions
- **User Profiles**: Customizable profiles with avatar uploads
- **Subscription Plans**: Multiple tiers (Free, Premium, VIP) with Stripe billing
- **Scoring System**: Automated weekly engagement scoring (Puntuació)
- **Admin Panel**: Comprehensive dashboard for user and content management

### 🏍️ Ride Organization (Sortides)
- **Event Creation**: Full-featured ride event management
- **GPS Integration**: GPX file upload and route visualization
- **Payment System**: Optional ride fees with Stripe checkout
- **OBERTA/TANCADA**: Free (€1) and premium ride types
- **Inscription Management**: Track participants and payment status
- **Real-time Updates**: Turbo-powered live updates

### 💬 Social Network (Piulades)
- **Rich Posts**: Text, images, and file attachments
- **Social Interactions**: Like, comment, and follow system
- **Activity Feed**: Personalized feed based on follows
- **Notifications**: Email notifications for all interactions
- **Polymorphic Likes**: Like posts, rides, and comments

### 🛒 E-commerce & Payments
- **Product Catalog**: Motorcycle gear and accessories
- **Shopping Cart**: Session-based cart with persistence
- **Stripe Payments**: Secure one-time and recurring payments
- **Donation System**: Support platform (€5-€100)
- **Webhook Processing**: Real-time Stripe event handling
- **Email Confirmations**: Automated receipts

### 🌍 Internationalization
- **Bilingual Support**: Complete Catalan and English translations
- **Localized Content**: Time zones, dates, currency (EUR)
- **Dynamic Language Switching**: User-selectable locale
- **Time Zone**: Europe/Paris (CET/CEST for Catalunya)

### 🎨 Modern Frontend
- **Tailwind CSS 4.0**: Utility-first responsive design
- **Radix UI**: Accessible component primitives
- **Stimulus.js**: Progressive JavaScript enhancement
- **Turbo**: SPA-like navigation without complex JS
- **React Components**: Modern UI elements with shadcn/ui

---

## 🛠️ Tech Stack

### Backend Technologies
- **Ruby 3.4.3** - Programming language
- **Rails 8.0** - Web application framework
- **MySQL/MariaDB** - Primary database
- **Redis** - Caching and session store
- **Sidekiq** - Background job processing
- **Stripe** - Payment processing platform
- **Devise** - Authentication solution

### Frontend Technologies
- **Tailwind CSS 4.0 beta** - Utility-first CSS framework
- **Stimulus.js** - JavaScript framework
- **Turbo** - Fast navigation framework
- **React 18** - Component library
- **Radix UI** - Accessible primitives
- **FontAwesome** - Icon library
- **Flowbite** - UI components

### Development Tools
- **RuboCop** - Ruby code linter
- **Brakeman** - Security scanner
- **ESLint** - JavaScript linter
- **Prettier** - Code formatter
- **Jest** - JavaScript testing
- **SimpleCov** - Test coverage
- **Webpack** - Module bundler

### DevOps & Infrastructure
- **Apache 2.4.62** - Web server
- **Passenger** - Application server
- **Let's Encrypt** - SSL certificates
- **Debian 12** - Operating system
- **RVM 1.29.12** - Ruby version manager
- **GitHub Actions** - CI/CD (optional)

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

- **Ruby 3.4.3** - Use RVM or rbenv
- **Rails 8.0+** - Latest stable version
- **MySQL/MariaDB 10.5+** - Database server
- **Node.js 18+** - JavaScript runtime
- **npm 11+** - Package manager
- **Redis 6+** - Cache server
- **ImageMagick** - Image processing

### System Requirements

- **OS**: Linux (Debian/Ubuntu), macOS, or Windows WSL2
- **Memory**: 4GB+ RAM (development), 8GB+ (production)
- **Storage**: 20GB+ available space
- **Network**: Stable internet for package downloads

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:coopeu/mc.git
   cd mc
   ```

2. **Install Ruby with RVM**
   ```bash
   # If RVM not installed
   curl -sSL https://get.rvm.io | bash
   source ~/.rvm/scripts/rvm

   # Install Ruby 3.4.3
   rvm install 3.4.3
   rvm use 3.4.3 --default

   # Verify installation
   ruby -v  # Should show 3.4.3
   ```

3. **Install dependencies**
   ```bash
   # Install Ruby gems
   bundle install

   # Install Node packages
   npm install
   ```

4. **Database setup**
   ```bash
   # Create database
   rails db:create

   # Run migrations
   rails db:migrate

   # Load seed data (optional)
   rails db:seed
   ```

5. **Configure credentials**
   ```bash
   # Edit Rails credentials
   EDITOR=nano rails credentials:edit
   ```

   Add the following structure:
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

6. **Start development servers**
   ```bash
   # Terminal 1: Rails server
   rails server

   # Terminal 2: Redis (if not running as service)
   redis-server

   # Terminal 3: Sidekiq background jobs
   bundle exec sidekiq

   # Terminal 4: Tailwind CSS watcher (optional)
   npm run build:css -- --watch
   ```

7. **Access the application**
   ```
   http://localhost:3000
   ```

### Verify Installation

```bash
# Check database connection
rails runner "puts 'Database: ' + (ActiveRecord::Base.connection.active? ? 'OK' : 'FAILED')"

# Check Redis connection
rails runner "puts 'Redis: ' + (Redis.new.ping == 'PONG' ? 'OK' : 'FAILED')"

# Check Stripe configuration
rails runner "puts 'Stripe: ' + (Stripe.api_key.present? ? 'OK' : 'MISSING')"
```

---

## 💻 Development

### Essential Commands

#### Development Server
```bash
# Start all services
bin/dev                          # Rails + Tailwind watcher

# Individual services
rails server                     # Rails on port 3000
bundle exec sidekiq              # Background jobs
redis-server                     # Cache/sessions
```

#### Database Operations
```bash
rails db:migrate                 # Run migrations
rails db:rollback                # Rollback last migration
rails db:seed                    # Load seed data
rails db:reset                   # Drop, create, migrate, seed
rails console                    # Interactive console
rails runner "User.count"        # Run Ruby code
```

#### Asset Management
```bash
npm run build                    # Development build
npm run build:prod               # Production build
npm run build:css                # Tailwind CSS compilation
rails assets:precompile          # Precompile all assets
```

### Code Quality

#### Linting & Formatting
```bash
# Ruby
bundle exec rubocop              # Check Ruby style
bundle exec rubocop -a           # Auto-fix issues

# JavaScript
npm run lint                     # ESLint check
npm run lint -- --fix            # Auto-fix JS issues
npm run format                   # Prettier format
```

#### Security Scanning
```bash
bundle exec brakeman             # Security vulnerabilities
bundle exec bundler-audit        # Dependency audit
```

#### Type Checking
```bash
npm run type-check               # TypeScript validation
```

### Background Jobs

```bash
# Start Sidekiq
bundle exec sidekiq

# Monitor jobs
bundle exec sidekiq -C config/sidekiq.yml

# Redis CLI for debugging
redis-cli monitor
```

---

## 📊 Project Structure

```
mc/
├── app/
│   ├── controllers/              # 25+ REST controllers
│   │   ├── admin/               # Admin dashboard
│   │   ├── charges_sortides_controller.rb
│   │   ├── charges_donations_controller.rb
│   │   ├── subscriptions_controller.rb
│   │   └── webhooks_controller.rb
│   │
│   ├── models/                   # 30+ ActiveRecord models
│   │   ├── concerns/            # FileValidatable, Likeable
│   │   ├── user.rb              # Devise authentication
│   │   ├── sortide.rb           # Ride events
│   │   ├── piulade.rb           # Social posts
│   │   └── puntuacio.rb         # Scoring system
│   │
│   ├── services/                # Business logic
│   │   ├── stripe_service.rb
│   │   ├── analytics_service.rb
│   │   ├── sortide_pricing_service.rb
│   │   └── rider_position_service.rb
│   │
│   ├── jobs/                    # Background processing
│   │   ├── puntuacio_setmanal_job.rb
│   │   └── daily_admin_summary_job.rb
│   │
│   ├── mailers/                 # Email notifications
│   │   ├── user_mailer.rb
│   │   └── admin_mailer.rb
│   │
│   └── javascript/              # Frontend code
│       ├── components/          # React components
│       ├── contexts/            # React contexts
│       └── controllers/         # Stimulus controllers
│
├── config/
│   ├── routes.rb               # 100+ routes
│   ├── database.yml            # DB configuration
│   ├── credentials.yml.enc     # Encrypted secrets
│   ├── locales/                # i18n translations
│   │   ├── ca.yml             # Catalan
│   │   └── en.yml             # English
│   └── initializers/
│
├── db/
│   ├── migrate/                # Database migrations
│   ├── schema.rb               # Current schema
│   └── seeds.rb                # Seed data
│
├── test/                       # 150+ tests
│   ├── controllers/            # Integration tests
│   ├── models/                 # Unit tests
│   ├── system/                 # E2E tests
│   ├── integration/            # Payment flows
│   └── support/                # Test helpers
│
├── scripts/                    # Automation scripts
├── public/                     # Static assets
├── storage/                    # Active Storage files
└── vendor/                     # Third-party code
```

### Key Files

- **Gemfile** - Ruby dependencies
- **package.json** - JavaScript dependencies
- **Dockerfile** - Container configuration
- **tailwind.config.js** - Tailwind CSS configuration
- **webpack.config.js** - Webpack bundler config
- **Rakefile** - Rake tasks

---

## 🔧 Configuration

### Rails Credentials

Production credentials are encrypted in `config/credentials.yml.enc`:

```bash
# Edit production credentials
EDITOR=nano RAILS_ENV=production rails credentials:edit
```

Required structure:
```yaml
# Stripe (REQUIRED for payments)
stripe:
  publishable_key: pk_live_...
  secret_key: sk_live_...
  webhook_secret: whsec_...

# Database (production)
username: motos_cat_user
password: secure_password

# SMTP (email)
SMTP_USERNAME: notifications@motos.cat
SMTP_PASSWORD: smtp_password

# Security
secret_key_base: (auto-generated)

# Optional services
recaptcha:
  site_key: ...
  secret_key: ...

redis_url: redis://localhost:6379/0
```

### Environment Variables

For development, create `.env` file:

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
DATABASE_URL=mysql2://root:password@localhost/mc_development
REDIS_URL=redis://localhost:6379/0
```

### Stripe Setup

1. **Create account** at [stripe.com](https://stripe.com)
2. **Get API keys** from Dashboard → Developers → API keys
3. **Configure webhook**:
   - URL: `https://yourdomain.com/webhook/stripe`
   - Events: `checkout.session.completed`, `invoice.payment_succeeded`, `customer.subscription.updated`
4. **Sync plans**: `rails runner "Plan.sync_with_stripe"`

---

## 🧪 Testing

### Test Suites

```bash
# Run all tests
rails test                       # Full suite
rails test:models                # Unit tests
rails test:controllers           # Integration tests
rails test:system                # E2E tests

# Specialized suites
rails test:stripe                # Payment flows
rails test:security              # Security validation
rails test:comprehensive         # Full with coverage

# JavaScript tests
npm test                         # Jest suite
npm run test:watch               # Watch mode
npm run test:coverage            # Coverage report
```

### Coverage Reports

```bash
# Run tests with coverage
rails test:comprehensive

# View HTML report
open coverage/index.html
```

### Test Data

Use Stripe test mode:
- **Test Card**: `4242 4242 4242 4242`
- **Expiry**: Any future date
- **CVC**: Any 3 digits
- **ZIP**: Any 5 digits

---

## 🚀 Deployment

### Production Environment

**Live Site**: motos.cat
- **Hosting**: HOSTIKA.lt (Lithuania)
- **Stack**: Debian 12 + Apache 2.4.62 + Passenger
- **Ruby**: 3.4.3 (via RVM)
- **Rails**: 8.0
- **Database**: MySQL/MariaDB
- **SSL**: Let's Encrypt
- **Directory**: `/var/www/html/motos.cat`

### Deployment Steps

1. **Server preparation**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y ruby-dev nodejs npm mysql-server redis-server \
                       imagemagick apache2 libapache2-mod-passenger
   ```

2. **Install RVM & Ruby**
   ```bash
   curl -sSL https://get.rvm.io | bash
   rvm install 3.4.3
   rvm use 3.4.3 --default
   ```

3. **Deploy application**
   ```bash
   cd /var/www/html
   git clone git@github.com:coopeu/mc.git motos.cat
   cd motos.cat

   bundle install --deployment --without development test
   npm install --production

   RAILS_ENV=production rails db:migrate
   RAILS_ENV=production rails assets:precompile

   chown -R www-data:www-data .
   ```

4. **Configure Apache**
   ```apache
   <VirtualHost *:443>
       ServerName motos.cat
       DocumentRoot /var/www/html/motos.cat/public

       PassengerRuby /home/user/.rvm/gems/ruby-3.4.3/wrappers/ruby
       PassengerAppEnv production

       SSLEngine on
       SSLCertificateFile /etc/letsencrypt/live/motos.cat/fullchain.pem
       SSLCertificateKeyFile /etc/letsencrypt/live/motos.cat/privkey.pem
   </VirtualHost>
   ```

5. **Start Sidekiq**
   ```bash
   sudo systemctl enable sidekiq-motoscat
   sudo systemctl start sidekiq-motoscat
   ```

### Health Checks

```bash
RAILS_ENV=production rails runner "puts 'Status: OK'"
RAILS_ENV=production rails runner "puts User.count"
curl -I https://motos.cat
```

---

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - AI assistant guide
- **[DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md)** - Dev environment
- **[PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)** - Production guide
- **[DEPLOYMENT_PROTOCOL.md](DEPLOYMENT_PROTOCOL.md)** - Deployment steps
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - API reference

---

## 🔒 Security

### Implemented Measures

- **File Upload Security**: FileValidatable concern with MIME validation
- **Payment Security**: PCI-compliant Stripe integration
- **Authentication**: Devise with secure sessions
- **Authorization**: Role-based access control
- **Input Validation**: XSS and SQL injection prevention
- **Security Headers**: HSTS, CSP, X-Frame-Options
- **Regular Scanning**: Brakeman vulnerability detection

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and add tests
4. Run test suite: `rails test:comprehensive`
5. Check code quality: `bundle exec rubocop && npm run validate`
6. Commit changes: `git commit -m "feat: add amazing feature"`
7. Push to branch: `git push origin feature/amazing-feature`
8. Create Pull Request

### Development Guidelines

- Follow Rails conventions
- Add comprehensive tests
- Use FileValidatable for uploads
- Consider database query performance
- Use Catalan naming for domain concepts

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Ruby on Rails** - Web framework
- **Stripe** - Payment processing
- **Tailwind CSS** - CSS framework
- **Stimulus & Turbo** - JavaScript frameworks
- **Devise** - Authentication
- **shadcn/ui** - UI components
- **Sidekiq** - Background jobs

---

## 📞 Support

- **Email**: coopeu@coopeu.com
- **Website**: [motos.cat](https://motos.cat)
- **Issues**: [GitHub Issues](https://github.com/coopeu/mc/issues)

---

**Built with ❤️ for the Catalan motorcycle community**
