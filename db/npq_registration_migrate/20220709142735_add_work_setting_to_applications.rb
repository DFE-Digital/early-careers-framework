class AddWorkSettingToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :work_setting, :text
  end
end
