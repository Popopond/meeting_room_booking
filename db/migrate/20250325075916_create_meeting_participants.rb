class CreateMeetingParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :meeting_participants do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :meeting_participants, [:booking_id, :user_id], unique: true
  end
end
