class RenameOldChildcareProviderUrnIntoDeprecatedChildcareProviderUrn < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :private_childcare_provider_urn_old, :DEPRECATED_private_childcare_provider_urn
  end
end
