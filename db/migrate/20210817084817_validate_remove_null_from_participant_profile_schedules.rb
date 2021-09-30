# frozen_string_literal: true

class ValidateRemoveNullFromParticipantProfileSchedules < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :participant_profiles, name: "participant_profiles_schedule_id_null"
    safety_assured { change_column_null :participant_profiles, :schedule_id, false }
    remove_check_constraint :participant_profiles, name: "participant_profiles_schedule_id_null"
  end
end
