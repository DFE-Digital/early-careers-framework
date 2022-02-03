# frozen_string_literal: true

class AddDefaultInductionProgrammeToSchoolCohorts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :school_cohorts, :default_induction_programme, null: true, index: { algorithm: :concurrently }
  end
end
