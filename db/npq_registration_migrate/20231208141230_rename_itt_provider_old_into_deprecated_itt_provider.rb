class RenameIttProviderOldIntoDeprecatedIttProvider < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :itt_provider_old, :DEPRECATED_itt_provider
  end
end
