class BookingMailer < ApplicationMailer
  def confirmation_email
    @booking = params[:booking]
    @user = @booking.user
    @room = @booking.room

    mail(
      from: "Pimpakan2545@gmail.com",
      to: @user.email,
      subject: "ยืนยันการจองห้องประชุม #{@room.name}"
    )
  end
end
