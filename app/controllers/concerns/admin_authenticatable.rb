module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    unless current_user&.role == 'admin'
      flash[:alert] = 'คุณไม่มีสิทธิ์เข้าถึงหน้านี้'
      redirect_to root_path
    end
  end
end 