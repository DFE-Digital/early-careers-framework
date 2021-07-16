# frozen_string_literal: true

class AddForeignKeySchoolCohortParticipantProfile < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :participant_profiles, :school_cohorts, column: :school_cohort_id, null: true, validate: false
  end
end
