# frozen_string_literal: true

class ContacteMailer < ApplicationMailer
  default to: 'info@motos.cat'

  def contacte_mailer(nom, email, telefon, missatge)
    @nom = nom
    @email = email
    @telefon = telefon
    @missatge = missatge
    mail(from: email, subject: 'Missatge des de Motos.cat contacte')
  end

  def contact_notification(contacte)
    @contacte = contacte
    mail(
      to: 'info@motos.cat',
      subject: "Nou missatge de contacte de #{@contacte.nom} des de Motos.cat"
    )
  end

  def confirmation_email(contacte)
    @contacte = contacte
    mail(
      to: @contacte.email,
      subject: 'Hem rebut el teu missatge - Motos.cat Mil Revolts'
    )
  end
end
