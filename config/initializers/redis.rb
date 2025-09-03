require 'redis'

redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
  timeout: 1,
  reconnect_attempts: 3
}

# Configure Redis for different environments
if Rails.env.production?
  redis_config.merge!(
    password: Rails.application.credentials.dig(:redis, :password),
    ssl: true,
    timeout: 5,
    reconnect_attempts: 5
  )
end

# Create Redis connection
REDIS = Redis.new(redis_config)

# Configure Sidekiq to use the same Redis instance
Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end

# Add health check
Rails.application.config.after_initialize do
  begin
    REDIS.ping
  rescue Redis::CannotConnectError => e
    Rails.logger.error "Redis connection failed: #{e.message}"
    raise e if Rails.env.production?
  end
end 