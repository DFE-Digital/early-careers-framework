# frozen_string_literal: true

class AddAppropriateBodiesToECFSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    add_column :ecf_school_cohorts, :appropriate_body_id, :uuid
    add_column :ecf_school_cohorts, :appropriate_body_unknown, :boolean
  end
end
