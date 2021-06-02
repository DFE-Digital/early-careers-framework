class AddOptOutOfUpdatesToSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    add_column :school_cohorts, :opt_out_of_updates, :boolean, null: false, default: :false
  end
end
