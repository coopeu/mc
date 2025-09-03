# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@motos.cat'
  layout 'mailer'
end
