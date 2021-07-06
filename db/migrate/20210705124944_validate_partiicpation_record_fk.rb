# frozen_string_literal: true

class ValidatePartiicpationRecordFk < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participation_records, :participant_profiles
  end
end
