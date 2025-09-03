# frozen_string_literal: true

class PurchasesInscripcion < ApplicationRecord
  after_create :email_purchaser

  has_one :product
  has_one :user

  def to_param
    uuid
  end

  def email_purchaser
    PurchaseMailer.purchase_receipt(self).deliver
  end
end
