class CreateBookingSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :booking_slots do |t|
      t.references :booking, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
