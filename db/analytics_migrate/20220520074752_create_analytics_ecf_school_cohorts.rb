# frozen_string_literal: true

class CreateAnalyticsECFSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    create_table :ecf_school_cohorts do |t|
      t.uuid :school_cohort_id
      t.uuid :school_id
      t.string :school_name
      t.string :school_urn
      t.uuid :cohort_id
      t.string :cohort
      t.string :induction_programme_choice
      t.string :default_induction_programme_training_choice
      t.timestamps
    end
  end
end
