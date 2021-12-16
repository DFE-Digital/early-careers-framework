# frozen_string_literal: true

class AddStartTermToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :start_term, :string, default: "Autumn 2021", null: false
  end
end
