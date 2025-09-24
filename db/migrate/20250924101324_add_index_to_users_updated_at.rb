# frozen_string_literal: true

class AddIndexToUsersUpdatedAt < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users, :updated_at, algorithm: :concurrently
  end
end
