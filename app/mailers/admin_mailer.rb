# frozen_string_literal: true

# app/mailers/admin_mailer.rb
class AdminMailer < ApplicationMailer
  ADMIN_EMAIL = 'info@motos.cat'

  def new_inscripcio(user, sortide)
    @user = user
    @user_profile_link = user_url(@user)
    @sortide = sortide
    @url = sortide_url(@sortide) # Generates the URL for the sortide
    mail(to: ADMIN_EMAIL, subject: "Inscripció a #{@sortide.title} de #{@user.slug}")
  end

  def new_user_registered(user)
    @user = user
    @user_profile_link = user_url(@user)
    mail(to: 'info@motos.cat', subject: 'New User Registered (Pending Approval)')
  end

  def report_user(user, reporter)
    @user = user
    @reporter = reporter
    @user_profile_link = user_url(@user)
    @reporter_profile_link = user_url(@reporter)
    mail(to: ADMIN_EMAIL, subject: 'Informe de motorista')
  end

  def new_sortide(sortide)
    @sortide = sortide
    @url = sortide_url(@sortide) # Generates the URL for the sortide
    mail(to: ADMIN_EMAIL, subject: 'New Sortide Created')
  end

  def new_user(user)
    @user = user
    @user_profile_link = user_url(@user)
    mail(to: ADMIN_EMAIL, subject: 'New User Registered (Pending Approval and slug)')
  end

  def test_email
    mail(
      to: 'info@motos.cat',
      subject: 'Test Email',
      body: 'This is a test email to verify SMTP dreamhost configuration.'
    )
  end

  def new_user_session(user)
    @user = user
    mail(to: 'info@motos.cat', subject: "Motorista #{@user.slug} ha iniciat sessió")
  end
end
