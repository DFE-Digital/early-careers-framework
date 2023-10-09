# frozen_string_literal: true

class ValidateCompletionCandidates < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :completion_candidates, :participant_profiles
  end
end
