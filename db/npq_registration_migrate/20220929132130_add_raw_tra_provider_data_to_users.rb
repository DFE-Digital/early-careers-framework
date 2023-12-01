class AddRawTraProviderDataToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :raw_tra_provider_data, :jsonb
  end
end
