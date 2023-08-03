# frozen_string_literal: true

class AddInductionCompletionDateToParticipantProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :participant_profiles, :induction_completion_date, :date
  end
end
