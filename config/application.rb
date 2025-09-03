require_relative 'boot'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Application < Rails::Application
  # Set the default locale to Catalan
  config.i18n.default_locale = :ca

  # Ensure the locale is available
  config.i18n.available_locales = %i[en ca]

  config.assets.paths << Rails.root.join('node_modules')

  # config/application.rb
  config.time_zone = 'Europe/Paris'
end
