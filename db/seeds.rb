# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create admin user
admin = User.find_or_create_by!(email: 'pimpakan2545@gmail.com') do |user|
  user.password = '123456'
  user.username = 'admin'
  user.role = 'admin'
end

puts "Created admin user: #{admin.email}"

# Create statuses
puts "Creating statuses..."
available_status = Status.find_or_create_by!(status_name: "Available")
Status.find_or_create_by!(status_name: "Unavailable")

# Create rooms
puts "Creating rooms..."
rooms_data = [
  {
    name: "Tea1",
    capacity: 4,
    description: "ห้องประชุมขนาดเล็ก เหมาะสำหรับการประชุมกลุ่มย่อย",
    status: available_status
  },
  {
    name: "Tea2",
    capacity: 4,
    description: "ห้องประชุมขนาดเล็ก เหมาะสำหรับการประชุมกลุ่มย่อย",
    status: available_status
  },
  {
    name: "Meeting1",
    capacity: 8,
    description: "ห้องประชุมขนาดกลาง พร้อมอุปกรณ์นำเสนอ",
    status: available_status
  },
  {
    name: "Meeting2",
    capacity: 8,
    description: "ห้องประชุมขนาดกลาง พร้อมอุปกรณ์นำเสนอ",
    status: available_status
  },
  {
    name: "Global",
    capacity: 20,
    description: "ห้องประชุมขนาดใหญ่ เหมาะสำหรับการประชุมใหญ่และสัมมนา",
    status: available_status
  },
  {
    name: "Record",
    capacity: 4,
    description: "ห้องอัดเสียง พร้อมอุปกรณ์บันทึกเสียงคุณภาพสูง",
    status: available_status
  }
]

rooms_data.each do |room_data|
  Room.find_or_create_by!(name: room_data[:name]) do |room|
    room.capacity = room_data[:capacity]
    room.description = room_data[:description]
    room.status = room_data[:status]
  end
end

puts "Seed completed successfully!"
