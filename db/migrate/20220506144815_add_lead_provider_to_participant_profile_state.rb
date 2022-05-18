# frozen_string_literal: true

class AddLeadProviderToParticipantProfileState < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference :participant_profile_states, :cpd_lead_provider, null: true, index: { algorithm: :concurrently }
  end
end
