class ChangeUserIdToBeNotNull < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured { change_column_null :participant_declarations, :user_id, false }
  end
end
