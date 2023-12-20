class RenameIttProviderFromApplication < ActiveRecord::Migration[7.0]
  def change
    rename_column :applications, :itt_provider, :itt_provider_old
  end
end
