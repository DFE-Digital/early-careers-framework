# frozen_string_literal: true

class AddProfileToParticipantDeclarations < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :participant_profile, index: { algorithm: :concurrently }
  end
end
