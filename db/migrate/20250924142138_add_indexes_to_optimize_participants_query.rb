# frozen_string_literal: true

class AddIndexesToOptimizeParticipantsQuery < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # InductionRecords
    add_index :induction_records, [:participant_profile_id, :end_date, :start_date], order: { start_date: :desc }, algorithm: :concurrently

    # Partnerships
    add_index :partnerships, :lead_provider_id, where: 'challenged_at IS NULL AND challenge_reason IS NULL', name: 'index_partnerships_on_lead_provider_id_where_challenged_is_null', algorithm: :concurrently
  end
end
