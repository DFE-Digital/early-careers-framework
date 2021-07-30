# frozen_string_literal: true

class RemoveNullConstraintFromParticipantsUserId < ActiveRecord::Migration[6.1]
  def change
    change_column_null :participant_profiles, :user_id, true
  end
end
