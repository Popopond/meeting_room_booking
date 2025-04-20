module QrCodeHelper
  def qrcode_room_url(room, options = {})
    room_qr_code_image_url(room, format: options[:format], token: room.room_qr_code.token)
  end
end
