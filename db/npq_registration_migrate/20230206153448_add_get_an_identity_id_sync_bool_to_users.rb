class AddGetAnIdentityIdSyncBoolToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :get_an_identity_id_synced_to_ecf, :boolean, default: false
  end
end
