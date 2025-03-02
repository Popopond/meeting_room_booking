class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :capacity
      t.string :description
      t.integer :status_id

      t.timestamps
    end
  end
end
