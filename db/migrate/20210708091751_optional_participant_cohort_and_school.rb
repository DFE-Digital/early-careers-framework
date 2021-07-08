# frozen_string_literal: true

class OptionalParticipantCohortAndSchool < ActiveRecord::Migration[6.1]
  def change
    change_column_null :participant_profiles, :cohort_id, true
    change_column_null :participant_profiles, :school_id, true
  end
end
