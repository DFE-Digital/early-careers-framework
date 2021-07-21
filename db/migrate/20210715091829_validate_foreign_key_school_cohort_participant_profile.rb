# frozen_string_literal: true

class ValidateForeignKeySchoolCohortParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :participant_profiles, :school_cohorts
  end
end
