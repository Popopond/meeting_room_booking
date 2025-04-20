class RoomQrCodesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_room

  def show
    # Generate QR code URL for the room
    qr_code_url = room_url(@room)

    # Generate QR code
    @qr = RQRCode::QRCode.new(qr_code_url, size: 10, level: :h)

    respond_to do |format|
      format.html
      format.png { send_data @qr.as_png(size: 300), type: "image/png", disposition: "inline" }
    end
  end

  def image
    qr_code_url = room_url(@room)
    qr = RQRCode::QRCode.new(qr_code_url, size: 10, level: :h)
    send_data qr.as_png(size: 300), type: "image/png", disposition: "inline"
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end
end
