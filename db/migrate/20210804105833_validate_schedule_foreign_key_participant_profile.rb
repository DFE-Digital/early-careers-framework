# frozen_string_literal: true

class ValidateScheduleForeignKeyParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_profiles, :schedules
  end
end
