class AddIttProviderIdToApplications < ActiveRecord::Migration[7.0]
  def change
    add_reference :applications, :itt_provider, null: true, foreign_key: true
  end
end
