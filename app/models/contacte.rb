# frozen_string_literal: true

class Contacte < ApplicationRecord
  EMAIL_REGEX = %r{\A[\w!#$%&'*+/=?`{|}~^-]+(?:\.[\w!#$%&'*+/=?`{|}~^-]+)*@(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}\z}
  validates :nom, :email, :telefon, :missatge, presence: true
  validates :email, format: { with: EMAIL_REGEX, message: 'ha de ser una adreça de correu electònic vàlid' }

  after_create :send_notifications

  private

  def send_notifications
    # Send email notifications
    ContactMailer.contact_notification(self).deliver_later
    ContactMailer.confirmation_email(self).deliver_later
  end
end
