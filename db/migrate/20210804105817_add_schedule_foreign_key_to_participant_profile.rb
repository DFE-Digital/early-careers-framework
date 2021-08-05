# frozen_string_literal: true

class AddScheduleForeignKeyToParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_profiles, :schedules, column: :schedule_id, null: true, validate: false
  end
end
