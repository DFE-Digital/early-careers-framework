class AddTeacherCatchmentSyncedToEcfToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :teacher_catchment_synced_to_ecf, :boolean, default: false
  end
end
