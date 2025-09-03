# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Ruby on Rails 7+/8 motorcycle social networking platform built for motos.cat with subscription management, ride organization, and social features. Uses Stripe for payments, Tailwind CSS for styling, and includes a comprehensive admin panel.

## DEV ENV Key Features

## LOCAL

W11 PRO N
BaseBoard ASUSTeK COMPUTER INC. ASUS MOTHRERBOARD 3x4TB mve2 ssd
ASUS PRIME Z790P 5500MHz
BIOS UEFI Version/Date American Megatrends Inc. 1604, 15/12/2023
MEMORY: 128MB DDR5 5600MHz
AHCI: PCIEX1 (G3) \*4 (SATA)
Processor 13th Gen Intel(R) Core(TM) i9-13900K, 3000 Mhz, 24 Core(s), 32 Logical Processor(s)
RAID:
STI2000MO127 12TB WESTERN DIGITAL 7300RPM 256MB CACHE 64MB BUFFER 6Gb/s SATA 3.0 3.5"N
FANXIANG S770 4TB
FANXIANG S880 4TB
NETAC NVMe SSD 4TB
USB:
WD 4TB TOSHIBA 640GB

---

INTEL PENTIUM i9 13000HX 2.20GHz
128 GB DRAM 5600MHz
NVIDIA GeForce RTX 4060 8GB VRAM
W11 Starting to SANDISK SSD 512GB
4 external disk

---

# ////////// REMOTE SERVER //////////////////////

## https://motos.cat on HOSTIKA.lt

Description: Debian GNU/Linux 12 (bookworm)
Apache/2.4.62 (Debian) + Passenger
ruby 3.3.5
Rails 8.0.3
Mysql/MariaDB
rvm 1.29.12
https OPENSSL Letsencrypt self-signed certificates
Motos.cat A 185.40.6.19 in HOSTIKA.lt
STRIPE motos.cat account: acct_1QSeF8RqLKaSIMq9
STRIPE MRCAT: acct_1QgqOyGye1N6CE33

## Architecture

Apache server + Passenger
/var/www/html/motos.cat

### Core Domains

- **User Management**: Devise authentication, profiles, subscription tiers
- **Ride Organization**: Sortides (rides), inscriptions, attendance tracking
- **Social Features**: Posts (piulades), likes, follows, comments
- **Commerce**: Products, carts, Stripe payments, subscription plans
- **Content Management**: Pages, categories, images, CMS features

### Key Models

- `User`: Devise-based with subscription status and roles
- `Sortide`: Ride events with inscriptions and comments
- `Piulade`: Social posts with likes/comments system
- `Product`/`Plan`: Commerce items with Stripe integration
- `Category`: Content organization
- `Cart`/`Purchase`: Shopping and order management

### Routing Patterns

- RESTful resources with Catalan naming conventions
- Nested routes for comments and images
- Custom endpoints for Stripe webhooks, user follows
- Static pages under `/pages` namespace

## Development Commands

### Setup & Installation

```bash
# Install dependencies
bundle install
yarn install

# Database setup
rails db:create db:migrate db:seed

# Start development server
bin/dev  # Runs Rails + Tailwind + CSS watch
```

### Testing

````bash
# Run all tests
rails test

# Run system tests
rails test:system

### Code Quality
```bash
# Lint Ruby code
rubocop
rubocop -a  # Auto-fix

# Type checking
yarn type-check

# Build assets
yarn build
yarn build:prod
````

### Database Operations

```bash
# Reset database
rails db:drop db:create db:migrate db:seed

# Generate migration
rails generate migration AddFieldToModel field:type

# Open console
rails console
```

### Background Jobs

```bash
# Start Sidekiq
bundle exec sidekiq

# Monitor jobs
redis-cli monitor
```

## Key Configuration

### Environment Variables

rails credentials:edit

- `STRIPE_PUBLISHABLE_KEY` / `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `RECAPTCHA_SITE_KEY` / `RECAPTCHA_SECRET_KEY`
- `REDIS_URL`
- Database credentials in `config/database.yml`

### Locale & Timezone

- Default locale: Catalan (`:ca`)
- Available locales: English, Catalan
- Timezone: Europe/Paris
- Assets: Tailwind CSS 4.0.0.beta4 + Webpack

### Payment Integration

- Stripe Checkout for one-time purchases
- Stripe Billing for subscriptions
- Webhook handling at `/webhook/stripe`
- Plans defined in `app/models/plan.rb`

## File Structure Highlights

### Controllers

- `SortidesController`: Ride management and inscriptions
- `UsersController`: Profile and social features
- `ProductsController`: Commerce with Stripe integration
- `AdminController`: Admin dashboard

### Services

- `StripeService`: Payment processing
- `RecaptchaEnterpriseService`: Security verification

### Background Jobs

- `PuntuacioSetmanalJob`: Weekly scoring calculations
- Stripe webhook processing via Sidekiq

## Common Development Tasks

### Adding New Ride Type

1. Update `Sortide` model with new fields
2. Add form fields in views/sortides/\_form.html.erb
3. Update controller strong params
4. Add translations in config/locales/ca.yml

### Stripe Integration Flow

1. Create checkout session via `StripeService`
2. Redirect to Stripe Checkout
3. Handle webhook at `WebhooksController#stripe`
4. Update user subscription status

### Social Features

- Follow system via `FollowsController`
- Like system via `LikesController`
- Comments via nested resources under piulades/sortides
