# frozen_string_literal: true

# app/jobs/puntuacioSetmanal_job.rb
class PuntuacioSetmanalJob
  include Sidekiq::Job

  def perform
    User.find_each(&:calculPuntuacio)
  end
end
