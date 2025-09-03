# frozen_string_literal: true

# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  ADMIN_EMAIL = 'info@motos.cat'

  def benvinguda_email(user)
    @user = user
    mail(to: @user.email, subject: 'Benvingut a Motos.cat Sortides en Moto per Catalunya')
  end

  def new_inscripcio(user, sortide)
    @user = user
    @user_profile_link = user_url(@user)
    @sortide = sortide
    @url = sortide_url(@sortide) # Generates the URL for the sortide
    mail(to: @user.email, subject: 'Gràcies per la teva inscripció a la sortida')
  end
end
