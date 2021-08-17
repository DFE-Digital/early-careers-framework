# frozen_string_literal: true

class RemoveNullFromParticipantProfileSchedules < ActiveRecord::Migration[6.1]
  def change
    change_column_null :participant_profiles, :schedule_id, true
  end
end
