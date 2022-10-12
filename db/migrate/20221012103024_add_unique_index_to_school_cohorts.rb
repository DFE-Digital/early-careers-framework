# frozen_string_literal: true

class AddUniqueIndexToSchoolCohorts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(:school_cohorts, %i[school_id cohort_id], unique: true, algorithm: :concurrently)
  end
end
