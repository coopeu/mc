# frozen_string_literal: true

# app/mailers/admin_report_user_mailer.rb
class AdminReportUserMailer < ApplicationMailer
  def report_user(user, reporter)
    @user = user
    @reporter = reporter
    @user_profile_link = user_url(@user)
    @reporter_profile_link = user_url(@reporter)
    mail(to: 'grup.motorista@milrevolts.cat', subject: 'Informe de motorista')
  end
end
