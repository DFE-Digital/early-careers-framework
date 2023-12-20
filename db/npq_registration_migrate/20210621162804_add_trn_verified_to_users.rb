class AddTrnVerifiedToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :trn_verified, :boolean, null: false, default: false
  end
end
