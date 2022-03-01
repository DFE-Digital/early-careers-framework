class AddLoginTokensToIdentities < ActiveRecord::Migration[6.1]
  def change
    add_column :identities, :login_token, :string
    add_column :identities, :login_token_valid_until, :datetime
    add_column :identities, :remember_created_at, :datetime
    add_column :identities, :last_sign_in_at, :datetime
    add_column :identities, :current_sign_in_at, :datetime
    add_column :identities, :current_sign_in_ip, :inet
    add_column :identities, :last_sign_in_ip, :inet
    add_column :identities, :sign_in_count, :integer, default: 0, null: false
  end
end
