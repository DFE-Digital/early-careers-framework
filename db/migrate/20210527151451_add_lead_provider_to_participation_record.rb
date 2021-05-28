# frozen_string_literal: true

class AddLeadProviderToParticipationRecord < ActiveRecord::Migration[6.1]
  def change
    add_reference :participation_records, :lead_provider, null: false, index: true, foreign_key: true, type: :uuid
  end
end
