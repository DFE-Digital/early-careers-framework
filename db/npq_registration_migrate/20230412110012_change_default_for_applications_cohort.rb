class ChangeDefaultForApplicationsCohort < ActiveRecord::Migration[6.1]
  def change
    change_column_default :applications, :cohort, from: 2021, to: nil
  end
end
