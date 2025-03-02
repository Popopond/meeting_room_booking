class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :complete
      t.string :confirmation_code

      t.timestamps
    end
  end
end
