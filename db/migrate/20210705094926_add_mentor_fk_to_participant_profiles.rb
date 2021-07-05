# frozen_string_literal: true

class AddMentorFkToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_profiles, :participant_profiles, column: :mentor_profile_id, validate: false
  end
end
