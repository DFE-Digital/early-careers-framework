# frozen_string_literal: true

class AddLeadProviderToCallOffContract < ActiveRecord::Migration[6.1]
  def change
    truncate_tables :participant_bands, :call_off_contracts
    add_reference :call_off_contracts, :lead_provider, null: false, default: "gen_random_uuid()", index: true, foreign_key: true
  end
end
