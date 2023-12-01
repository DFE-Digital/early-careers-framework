class AddTrnLookupStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :trn_lookup_status, :string
  end
end
