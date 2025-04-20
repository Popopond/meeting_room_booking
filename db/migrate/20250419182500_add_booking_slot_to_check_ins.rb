class AddBookingSlotToCheckIns < ActiveRecord::Migration[8.0]
  def change
    add_reference :check_ins, :booking_slot, null: false, foreign_key: true
  end
end 