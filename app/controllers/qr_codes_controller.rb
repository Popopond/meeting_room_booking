class QrCodesController < ApplicationController
  before_action :authenticate_user!

  def room
    @room = Room.find(params[:room_id])
    qr_code_url = room_url(@room)
    qr = RQRCode::QRCode.new(qr_code_url, size: 10, level: :h)

    send_data qr.as_png(size: 300), type: "image/png", disposition: "inline"
  end
end
