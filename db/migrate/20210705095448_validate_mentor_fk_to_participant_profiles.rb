# frozen_string_literal: true

class ValidateMentorFkToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_profiles, :participant_profiles
  end
end
