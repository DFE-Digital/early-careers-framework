# frozen_string_literal: true

class AddParticipantIdentityToNPQApplications < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :npq_applications, :participant_identity, null: true, index: { algorithm: :concurrently }
  end
end
