# frozen_string_literal: true

class RemoveStartTermFromParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :participant_profiles, :start_term, :string, default: "Autumn 2021", null: false
    end
  end
end
