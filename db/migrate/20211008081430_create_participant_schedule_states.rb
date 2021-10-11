# frozen_string_literal: true

class CreateParticipantScheduleStates < ActiveRecord::Migration[6.1]
  def change
    create_table :participant_profile_schedules do |t|
      t.references :participant_profile, null: false, foreign_key: true
      t.references :schedule, null: false, foreign_key: true
      t.timestamps
    end
  end
end
