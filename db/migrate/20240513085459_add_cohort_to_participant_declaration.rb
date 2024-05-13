# frozen_string_literal: true

class AddCohortToParticipantDeclaration < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_declarations, :cohort, null: true, index: { algorithm: :concurrently }
  end
end
