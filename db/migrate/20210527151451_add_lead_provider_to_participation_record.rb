# frozen_string_literal: true

class AddLeadProviderToParticipationRecord < ActiveRecord::Migration[6.1]
  def change
    add_reference :participation_records, :lead_provider, null: true, index: true, foreign_key: true, type: :uuid
    ParticipationRecord.all.each do |pr|
      pr.update(lead_provider_id: pr.early_career_teacher&.user&.lead_provider_id || gen_random_uuid)
    end
    change_column_null :participation_records, :lead_provider_id, false, "gen_random_uuid()"
  end
end
