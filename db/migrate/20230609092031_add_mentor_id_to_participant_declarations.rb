# frozen_string_literal: true

class AddMentorIdToParticipantDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :mentor, type: :uuid, index: { algorithm: :concurrently }
  end
end
