# frozen_string_literal: true

class AddStatusToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :status, :text, null: false, default: "active"
  end
end
