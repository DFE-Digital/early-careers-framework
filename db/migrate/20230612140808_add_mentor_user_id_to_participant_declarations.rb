# frozen_string_literal: true

class AddMentorUserIdToParticipantDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :mentor_user, type: :uuid, index: { algorithm: :concurrently }
    add_foreign_key :participant_declarations, :users, column: :mentor_user_id, validate: false
  end
end
