class AddCompleteToBookingSlots < ActiveRecord::Migration[8.0]
  def change
    add_column :booking_slots, :complete, :boolean, default: false
  end
end
