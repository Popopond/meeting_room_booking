class CreateRoomQrCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :room_qr_codes do |t|
      t.references :room, null: false, foreign_key: true
      t.string :token, null: false
      t.timestamps
    end

    add_index :room_qr_codes, :token, unique: true
  end
end
