# frozen_string_literal: true

class AddProfileDuplicityToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :profile_duplicity, :string, null: false, default: "single"
  end
end
