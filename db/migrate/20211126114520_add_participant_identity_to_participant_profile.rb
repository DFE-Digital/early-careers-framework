# frozen_string_literal: true

class AddParticipantIdentityToParticipantProfile < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profiles, :participant_identity, null: true, index: { algorithm: :concurrently }
  end
end
