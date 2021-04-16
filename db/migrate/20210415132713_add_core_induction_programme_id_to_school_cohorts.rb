# frozen_string_literal: true

class AddCoreInductionProgrammeIdToSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    add_reference :school_cohorts, :core_induction_programme, foreign_key: true, index: true
  end
end
