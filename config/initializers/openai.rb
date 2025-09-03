class OpenAI
  def initialize
    @api_key = Rails.application.credentials.dig(:OPENAI_API_KEY)
  end

  def call_openai_api(prompt)
    # Use the @api_key to authenticate requests to the OpenAI API
  end
end