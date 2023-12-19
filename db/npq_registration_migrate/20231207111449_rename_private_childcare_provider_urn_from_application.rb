class RenamePrivateChildcareProviderUrnFromApplication < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :private_childcare_provider_urn, :private_childcare_provider_urn_old
  end
end
