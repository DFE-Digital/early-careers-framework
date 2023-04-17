# frozen_string_literal: true

class AddIndexToParticipantProfileStates < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :participant_profile_states, %i[participant_profile_id state cpd_lead_provider_id], algorithm: :concurrently, name: "index_on_profile_and_state_and_lead_provider"
    add_index :participant_profile_states, %i[participant_profile_id cpd_lead_provider_id], algorithm: :concurrently, name: "index_on_profile_and_lead_provider"
  end
end
