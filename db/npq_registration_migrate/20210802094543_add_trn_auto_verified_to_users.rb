class AddTrnAutoVerifiedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :trn_auto_verified, :boolean, default: false
  end
end
