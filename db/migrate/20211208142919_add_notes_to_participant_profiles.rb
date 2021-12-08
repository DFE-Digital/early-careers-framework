# frozen_string_literal: true

class AddNotesToParticipantProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :notes, :string
  end
end
