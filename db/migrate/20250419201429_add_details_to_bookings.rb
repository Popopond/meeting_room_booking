class AddDetailsToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :description, :text
    add_column :bookings, :expected_participants, :integer
  end
end
