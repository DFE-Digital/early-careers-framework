class AddPrivateChildcareProviderIdToApplications < ActiveRecord::Migration[7.0]
  def change
    add_reference :applications, :private_childcare_provider, null: true, foreign_key: true
  end
end
