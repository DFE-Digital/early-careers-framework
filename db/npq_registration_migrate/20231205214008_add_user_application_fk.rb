class AddUserApplicationFk < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :applications, :users, column: :user_id
  end
end
