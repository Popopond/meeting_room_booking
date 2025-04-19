class RegistrationsController < Devise::RegistrationsController
  protected

  def update_resource(resource, params)
    # If password is present, update password
    if params[:password].present?
      resource.update_with_password(params)
    else
      # Remove password keys if password is blank
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      
      # Update without password
      resource.update_without_password(params)
    end
  end
end 