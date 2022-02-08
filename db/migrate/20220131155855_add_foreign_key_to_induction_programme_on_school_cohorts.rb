# frozen_string_literal: true

class AddForeignKeyToInductionProgrammeOnSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :school_cohorts, :induction_programmes, column: :default_induction_programme_id, validate: false
  end
end
