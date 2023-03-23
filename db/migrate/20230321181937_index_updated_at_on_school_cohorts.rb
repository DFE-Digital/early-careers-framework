# frozen_string_literal: true

class IndexUpdatedAtOnSchoolCohorts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :school_cohorts, :updated_at, algorithm: :concurrently
  end
end
