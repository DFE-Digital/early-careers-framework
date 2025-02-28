# frozen_string_literal: true

class AddVoidedByAndVoidedAtToParticipantDeclarations < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :participant_declarations, :voided_at, :datetime
    add_reference :participant_declarations, :voided_by_user, null: true, index: { algorithm: :concurrently }
  end
end
