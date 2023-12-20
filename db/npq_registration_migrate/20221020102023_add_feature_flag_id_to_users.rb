class AddFeatureFlagIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :feature_flag_id, :string, unique: true
  end
end
