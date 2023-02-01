# frozen_string_literal: true

class AddGetAnIdentityIdIndexToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :users, :get_an_identity_id, algorithm: :concurrently
  end
end
