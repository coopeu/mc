# frozen_string_literal: true

class Subscriptor < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: VALID_EMAIL_REGEX },
            length: { maximum: 255 }

  validate :email_domain_exists
  validate :email_not_blacklisted

  before_save { self.email = email.downcase }

  private

  def email_domain_exists
    domain = email.split('@').last
    errors.add(:email, 'domain does not exist') unless domain_exists?(domain)
  end

  def domain_exists?(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::MX).any?
    end
  rescue SocketError
    false
  end

  def email_not_blacklisted
    domain = email.split('@').last.downcase
    return unless disposable_email_domains.include?(domain)

    errors.add(:email, 'from disposable email providers are not allowed')
  end

  def disposable_email_domains
    @disposable_email_domains ||= [
      'yopmail.com',
      'tempmail.com',
      'throwawaymail.com',
      'mailinator.com',
      '10minutemail.com',
      'guerrillamail.com'
      # Add more disposable email domains as needed
    ]
  end
end
