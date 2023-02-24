# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :participant_declarations, :declaration_type, algorithm: :concurrently
    add_index :participant_outcomes, :state, algorithm: :concurrently
    add_index :participant_outcomes, :sent_to_qualified_teachers_api_at, algorithm: :concurrently
    add_index :participant_outcomes, :created_at, algorithm: :concurrently
  end
end
