# frozen_string_literal: true

class AddTypeIndexToParticipantDeclarations < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :participant_declarations, :type, algorithm: :concurrently
  end
end
