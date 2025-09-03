## Development Environment Overview

### **Primary Projects**

- **motos.cat** - Main Ruby on Rails application (last active July 16, 20:30)

  - Rails 7+/8 moto riders/rides application with Stripe integration
  - Subscription management system
  - User regsitartion, authentication and payment processing

- **coopeu.com** - Another web application (likely production)

- **mc, mr, mrc** - Additional Rails projects (possibly staging/testing environments)

### **Database & Admin Tools**

- **phpmyadmin** - MySQL database management interface
- **adminer** - Lightweight database management tool (single PHP file)
- **MariaDB/MySQL** - Database server (inferred from Rails apps)

### **Development Infrastructure**

- **Backup Strategy**: Automated daily backups (`motos.cat.20250716`, `motos.cat.20250717`)
- **Environment Management**: `.env` file for configuration
- **Version Control**: Git repositories throughout projects
- **SSH Access**: `ssh_connect.bat` for Windows-based connections

### **Technology Stack**

- **Backend**: Ruby on Rails (this app)
- **Frontend**: ERB templates, Tailwind CSS
- **Payments**: Stripe integration (see Stripe section below)
- **Database**: MySQL/MariaDB fcv:Consenorg3005

### **Key Configuration Files**

- `stripe.txt` - Complete Stripe setup documentation
- `PC_W11-PS_Debian12.txt` - System configuration notes
- `AI Implementation Guide for Motos.cat.md` - AI integration documentation
- `.env` - Environment variables and secrets

### **Development Workflow**

- **Local Development**: VSCode on Windows 11 → SSH to Debian 12 server
- **Staging**: Multiple project versions for testing
- **Production**: motos.cat and coopeu.com the two main production sites
- **Monitoring**: Comprehensive logging and backup systems

This is a well-structured Rails development environment with proper separation of concerns, automated backups, and integrated payment processing capabilities.

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
npm ci

# Database setup
rails db:create db:migrate db:seed

# Start development server
bin/dev  # Runs Rails + Tailwind + CSS watch
```

### Testing

```bash
# Run all tests
rails test

# Run system tests
rails test:system
```

### Code Quality
```bash
# Lint Ruby code
rubocop
rubocop -a  # Auto-fix

# Type checking
npm run type-check

# Build assets
npm run build
npm run build:prod
```

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

## Troubleshooting

- Tailwind error during tests (e.g., unknown utility): tests disable the Tailwind build with a no-op Rake task in `lib/tasks/tailwind_test_noop.rake`.
- Webhook 400 responses: verify `STRIPE_WEBHOOK_SECRET` and that the `Stripe-Signature` header is present.
- Database test failures: ensure `motoscat_test` exists and schema is up to date, or keep webhook tests DB-independent (no fixtures).

## Roadmap
## Admin Utilities

### Catalonia Riders Map

View all approved riders on an interactive map:

```bash
# Visit in browser
https://motos.cat/maps/riders
```

Features:
- Interactive map centered on Catalonia
- Filter by province and subscription plan
- Click markers to see rider details
- Color-coded markers by plan type

### Geocode Users

Add coordinates to existing users for the map:

```bash
bundle exec rake users:geocode
```

### Validate Stripe Prices

Check that each `Plan` points to a valid Stripe Price ID (`sku` preferred, fallback `codi`):

```bash
STRIPE_SECRET_KEY=sk_test_123 bundle exec rake stripe:validate_prices
```

Output examples:

- `[OK] Plan #3 'HABITUAL' => Price price_123 (29.0 eur)`
- `[NOT FOUND] Plan #2 'FREQÜENT' => Price 'price_bad' (No such price: 'price_bad')`

- Handle `checkout.session.completed` and `payment_intent.succeeded` with concrete domain updates
- Add request specs for additional webhooks
- Document admin workflows and content management

## Getting Started

### 1) Environment Variables

Create `.env` or set environment variables in your shell (values are examples):

```bash
STRIPE_PUBLISHABLE_KEY=pk_test_123
STRIPE_SECRET_KEY=sk_test_123
# This is the signing secret for your webhook endpoint
STRIPE_WEBHOOK_SECRET=whsec_123

# Database (if not using credentials)
DB_USERNAME=motos
DB_PASSWORD=secret

# Recaptcha (optional)
RECAPTCHA_SITE_KEY=
RECAPTCHA_SECRET_KEY=

# Redis (optional)
REDIS_URL=redis://localhost:6379/1
```

Then install and run:

```bash
bundle install
npm ci
rails db:create db:migrate
bin/dev
```

### 2) Stripe Webhook Setup (Local)

Option A: Stripe CLI (recommended)

```bash
# Log in first (one-time)
stripe login

# Forward events to your local server (update port if different)
stripe listen --forward-to localhost:3000/webhook/stripe

# The CLI prints a signing secret like: whsec_xxx
# Copy that value to STRIPE_WEBHOOK_SECRET
```

Option B: ngrok (or similar)

```bash
ngrok http 3000
# Configure the public URL in your Stripe Dashboard → Developers → Webhooks
# Endpoint: POST https://<your-ngrok>.ngrok.app/webhook/stripe
# Signing secret: copy to STRIPE_WEBHOOK_SECRET
```

### 3) Create a Test Checkout Session (optional)

Use your app's UI flow or the Stripe CLI to trigger events:

```bash
# Example: create a PaymentIntent (adapt to your flow)
stripe payment_intents create \
  --amount 2000 \
  --currency eur

# Or create a Checkout Session
stripe checkout sessions create \
  --mode payment \
  --success_url "http://localhost:3000/success" \
  --cancel_url "http://localhost:3000/cancel" \
  --line-items "price=price_123,quantity=1"
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

#### Stripe Webhooks

- Set `STRIPE_WEBHOOK_SECRET` in the environment where webhooks are received.
- Stripe sends events to: `POST /webhook/stripe`.
- Webhook signature is verified via `Stripe::Webhook.construct_event` in `WebhooksController`.
- Extend `handle_stripe_event` to connect events to domain logic.

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

