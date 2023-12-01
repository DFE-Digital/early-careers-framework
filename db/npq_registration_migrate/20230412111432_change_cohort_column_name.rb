class ChangeCohortColumnName < ActiveRecord::Migration[6.1]
  def change
    rename_column :applications, :cohort, :DEPRECATED_cohort
  end
end
