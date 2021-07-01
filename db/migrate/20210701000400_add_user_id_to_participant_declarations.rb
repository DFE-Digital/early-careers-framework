# frozen_string_literal: true

class AddUserIdToParticipantDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :user, null: true, type: :uuid, index: { algorithm: :concurrently }
  end
end
