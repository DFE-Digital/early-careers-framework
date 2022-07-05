# frozen_string_literal: true

class AddAppropriateBodyToSchoolCohort < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :school_cohorts, :appropriate_body, null: true
      add_column :school_cohorts, :appropriate_body_unknown, :boolean, default: false, null: false
    end
  end
end
