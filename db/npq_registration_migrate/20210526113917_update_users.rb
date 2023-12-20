class UpdateUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :encrypted_password, :text, null: false, default: ""

    add_column :users, :ecf_id, :text
    add_column :users, :trn, :text

    add_column :users, :first_name, :text
    add_column :users, :last_name, :text

    add_column :users, :otp_hash, :text
    add_column :users, :otp_expires_at, :datetime

    add_index :users, :ecf_id, unique: true
  end
end
