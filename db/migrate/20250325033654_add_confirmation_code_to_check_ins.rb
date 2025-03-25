class AddConfirmationCodeToCheckIns < ActiveRecord::Migration[8.0]
  def change
    add_column :check_ins, :confirmation_code, :string
  end
end
