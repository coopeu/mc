# frozen_string_literal: true

class RecaptchaEnterpriseService
  def self.verify(token:, action:)
    new.verify(token: token, action: action)
  end

  def verify(token:, action:)
    return false if token.blank?

    uri = URI('https://www.google.com/recaptcha/api/siteverify')
    response = Net::HTTP.post_form(uri, {
                                     'secret' => secret_key,
                                     'response' => token,
                                     'remoteip' => nil # Optional: Add if you want to verify the user's IP
                                   })

    result = JSON.parse(response.body)

    if result['success']
      Rails.logger.info 'reCAPTCHA verification successful'
      true
    else
      Rails.logger.error "reCAPTCHA verification failed: #{result['error-codes']&.join(', ')}"
      false
    end
  rescue StandardError => e
    Rails.logger.error "reCAPTCHA verification failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end

  private

  def secret_key
    '6LemNl0rAAAAAC1n3I-oAYwB-pqJftaaeIcxHJNp'
  end
end
