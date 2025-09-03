Rails.logger.debug "=== Loading hCaptcha Configuration ==="

begin
  Hcaptcha.configure do |config|
    site_key = Rails.application.credentials.dig(:hcaptcha, :site_key)
    secret_key = Rails.application.credentials.dig(:hcaptcha, :secret_key)
    
    Rails.logger.debug "hCaptcha site key present?: #{site_key.present?}"
    Rails.logger.debug "hCaptcha secret key present?: #{secret_key.present?}"
    
    config.site_key = site_key
    config.secret_key = secret_key
    config.verify_url = 'https://hcaptcha.com/siteverify'
  end
rescue => e
  Rails.logger.error "Failed to configure hCaptcha: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
end