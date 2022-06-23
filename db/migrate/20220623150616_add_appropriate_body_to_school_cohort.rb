# frozen_string_literal: true

class AddAppropriateBodyToSchoolCohort < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :school_cohorts, :appropriate_body, null: true
    end
  end
end
