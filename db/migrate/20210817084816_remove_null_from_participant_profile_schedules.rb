# frozen_string_literal: true

class RemoveNullFromParticipantProfileSchedules < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :participant_profiles, "schedule_id IS NOT NULL", name: "participant_profiles_schedule_id_null", validate: false
  end
end
