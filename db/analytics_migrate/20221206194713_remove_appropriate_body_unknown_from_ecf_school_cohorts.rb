# frozen_string_literal: true

class RemoveAppropriateBodyUnknownFromECFSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :ecf_school_cohorts, :appropriate_body_unknown, :boolean
    end
  end
end
