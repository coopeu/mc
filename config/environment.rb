# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

# Ensure the cache store is configured correctly
Rails.application.config.cache_store = :mem_cache_store, { namespace: 'mr', compress: true, pool_size: 5 }

