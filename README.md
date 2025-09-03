# 🏍️ motos.cat - Motorcycle Social Network Platform

[![Ruby](https://img.shields.io/badge/Ruby-3.4-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-green.svg)](#)

A comprehensive motorcycle social networking platform built with Ruby on Rails, featuring ride organization, social interactions, e-commerce, and subscription management with Stripe integration.

## 🌟 Features

### 🏗️ Core Platform Features
- **User Authentication & Profiles** - Secure registration with Devise, comprehensive user profiles
- **Ride Organization (Sortides)** - Create, manage, and join motorcycle rides with GPS integration
- **Social Network (Piulades)** - Share posts, photos, like and comment system
- **E-commerce Integration** - Product catalog with shopping cart and secure payments
- **Subscription Management** - Multiple membership tiers with Stripe billing
- **Admin Dashboard** - Comprehensive content and user management

### 🔒 Security & File Management
- **Advanced File Upload Validation** - MIME type, extension, and malicious content detection
- **Image Processing** - Automatic resizing, dimension validation, and optimization
- **Security Scanning** - Brakeman integration for vulnerability detection
- **Input Sanitization** - XSS and injection attack prevention

### 💳 Payment Integration
- **Stripe Payment Processing** - Secure one-time and recurring payments
- **Webhook Handling** - Real-time payment event processing
- **Subscription Billing** - Automated recurring billing with plan management
- **Multi-currency Support** - EUR primary with extensible currency system

### 🧪 Testing & Quality
- **Comprehensive Test Suite** - 80%+ code coverage with SimpleCov
- **Payment Flow Testing** - Complete Stripe integration testing with VCR
- **Security Testing** - File upload and authentication security tests
- **System Testing** - End-to-end user journey validation

## 🚀 Quick Start

### Prerequisites

- Ruby 3.4+
- Rails 8.0+
- MySQL/MariaDB
- Node.js 18+
- Redis (for background jobs)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/coopeu/MotosCat.git
   cd MotosCat
   ```

2. **Install dependencies**
   ```bash
   bundle install
   yarn install
   ```

3. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```

Visit `http://localhost:3000` to access the application.

## 🛠️ Development

### Smart Git Workflow

The project includes an intelligent Git workflow system:

```bash
# Smart commit with auto-generated messages
./scripts/git-smart-commit.sh commit

# Complete workflow: add, commit, push
./scripts/git-smart-commit.sh full

# Create feature branch with intelligent naming
./scripts/git-smart-commit.sh branch create
```

See [Git Workflow Guide](docs/GIT_WORKFLOW.md) for detailed usage.

### Code Quality

```bash
# Run RuboCop for code style
bundle exec rubocop

# Run security scan
bundle exec brakeman

# Run test suite with coverage
rails test
```

### Testing

```bash
# Run all tests
rails test

# Run specific test suites
rails test:stripe          # Stripe payment tests
rails test:security        # Security-focused tests
rails test:comprehensive   # Full test suite with coverage
```

## 📊 Project Structure

```
motos.cat/
├── app/
│   ├── controllers/       # Request handling and API endpoints
│   ├── models/           # Data models and business logic
│   │   └── concerns/     # Shared model functionality
│   ├── views/            # ERB templates and UI components
│   ├── services/         # Business logic services
│   └── javascript/       # Stimulus controllers and JS
├── config/               # Application configuration
├── db/                   # Database migrations and schema
├── test/                 # Comprehensive test suite
│   ├── controllers/      # Controller integration tests
│   ├── models/          # Model unit tests
│   ├── system/          # End-to-end system tests
│   └── support/         # Test helpers and utilities
├── scripts/             # Development and deployment scripts
└── docs/                # Project documentation
```

## 🔧 Configuration

### Environment Variables

Key configuration variables (see `.env.example`):

```bash
# Database
DATABASE_URL=mysql2://user:password@localhost/motos_cat

# Stripe Payment Processing
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Redis (for background jobs)
REDIS_URL=redis://localhost:6379/0

# Security
SECRET_KEY_BASE=your_secret_key_base
```

### Stripe Configuration

1. Create a Stripe account at [stripe.com](https://stripe.com)
2. Get your API keys from the Stripe dashboard
3. Configure webhook endpoints for payment events
4. Set up your products and pricing plans

## 🚀 Deployment

### Production Setup

1. **Server Requirements**
   - Ubuntu 20.04+ or similar
   - Ruby 3.4+, Rails 8.0+
   - MySQL/MariaDB
   - Redis
   - Nginx (recommended)

2. **Deploy with Docker**
   ```bash
   docker build -t motos-cat .
   docker run -p 3000:3000 motos-cat
   ```

3. **Manual Deployment**
   ```bash
   # Set production environment
   export RAILS_ENV=production
   
   # Install dependencies
   bundle install --without development test
   
   # Precompile assets
   rails assets:precompile
   
   # Run migrations
   rails db:migrate
   
   # Start server
   rails server -e production
   ```

### GitHub Repository Setup

To push to GitHub:

```bash
# Run the automated setup script
./scripts/setup-github-remote.sh

# Or manually configure
git remote add origin https://github.com/coopeu/MotosCat.git
git push -u origin main
```

## 📚 Documentation

- [Git Workflow Guide](docs/GIT_WORKFLOW.md) - Intelligent Git operations and branch management
- [API Documentation](docs/API.md) - REST API endpoints and usage
- [Deployment Guide](docs/DEPLOYMENT.md) - Production deployment instructions
- [Contributing Guide](CONTRIBUTING.md) - Development guidelines and standards

## 🧪 Testing

The project includes comprehensive testing:

- **Unit Tests** - Model validations and business logic
- **Integration Tests** - Controller and API endpoint testing
- **System Tests** - End-to-end user journey validation
- **Security Tests** - File upload and authentication security
- **Payment Tests** - Complete Stripe integration testing

Run tests with coverage reporting:

```bash
rails test:comprehensive
open coverage/index.html  # View coverage report
```

## 🔒 Security

Security measures implemented:

- **File Upload Validation** - Comprehensive malicious file detection
- **Input Sanitization** - XSS and injection prevention
- **Authentication** - Secure user authentication with Devise
- **Authorization** - Role-based access control
- **Payment Security** - PCI-compliant Stripe integration
- **Regular Security Scans** - Automated vulnerability detection

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and add tests
4. Run the test suite: `rails test`
5. Commit with conventional messages: `./scripts/git-smart-commit.sh commit`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Ruby on Rails** - Web application framework
- **Stripe** - Payment processing platform
- **Tailwind CSS** - Utility-first CSS framework
- **Stimulus** - JavaScript framework for Rails
- **Devise** - Authentication solution
- **RuboCop** - Code style and quality tool

## 📞 Support

For support and questions:

- **Email**: coopeu@coopeu.com
- **Website**: [motos.cat](https://motos.cat)
- **Issues**: [GitHub Issues](https://github.com/coopeu/MotosCat/issues)

---

**Built with ❤️ for the motorcycle community in Catalunya**
