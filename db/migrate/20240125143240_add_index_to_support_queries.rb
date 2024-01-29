# frozen_string_literal: true

class AddIndexToSupportQueries < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :support_queries, :subject, unique: false, algorithm: :concurrently
    add_index :support_queries, [:user_id, :subject], unique: false, algorithm: :concurrently
  end
end
