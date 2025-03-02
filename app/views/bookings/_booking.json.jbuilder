json.extract! booking, :id, :user_id, :room_id, :start_time, :end_time, :created_at, :complete, :confirmation_code, :created_at, :updated_at
json.url booking_url(booking, format: :json)
