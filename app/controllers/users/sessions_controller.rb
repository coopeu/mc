# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    def create
      super do |user|
        unless user.admin?
          formatted_login_time = Time.current.strftime('%Y-%m-%d %H:%M')
          Session.create(user: user, login_time: formatted_login_time)
        end
      end
    end

    def after_sign_in_path_for(resource)
      AdminMailer.new_user_session(resource).deliver_later unless resource.admin?
      stored_location_for(resource) || root_path
    end
  end
end
