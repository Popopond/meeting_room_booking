class SessionsController < Devise::SessionsController
  def create
    super do |resource|
      if resource.persisted?
        flash[:notice] = "เข้าสู่ระบบสำเร็จ"
      end
    end
  end
end
