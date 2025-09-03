# frozen_string_literal: true

# app/controllers/users/passwords_controller.rb
module Users
  class PasswordsController < Devise::PasswordsController
    # PUT /resource/password
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      if resource.errors.empty?
        resource.assign_attributes(password_params)
        if resource.save(validate: false)
          resource.unlock_access! if unlockable?(resource)
          flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
          set_flash_message(:notice, flash_message) if is_flashing_format?
          sign_in(resource_name, resource)
          respond_with resource, location: after_resetting_password_path_for(resource)
        else
          respond_with resource
        end
      else
        respond_with resource
      end
    end

    private

    def password_params
      params.expect(user: [:password, :password_confirmation])
    end
  end
end
