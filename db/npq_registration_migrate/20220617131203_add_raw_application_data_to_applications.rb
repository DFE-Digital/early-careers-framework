class AddRawApplicationDataToApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :raw_application_data, :jsonb, default: {}
  end
end
