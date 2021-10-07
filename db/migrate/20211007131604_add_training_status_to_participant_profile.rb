# frozen_string_literal: true

class AddTrainingStatusToParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_profiles, :training_status, :string
  end
end
