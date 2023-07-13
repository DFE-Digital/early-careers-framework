# frozen_string_literal: true

module Api::Concerns::FetchLatestInductionRecords
  extend ActiveSupport::Concern

protected

  def latest_induction_records_join
    InductionRecord
      .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
      .joins(:participant_profile, { induction_programme: :partnership })
      .where(
        induction_programme: {
          partnerships: {
            lead_provider_id: lead_provider.id,
            challenged_at: nil,
            challenge_reason: nil,
          },
        },
      )
  end

  def latest_induction_record_order
    <<~SQL
      PARTITION BY induction_records.participant_profile_id ORDER BY
        CASE
          WHEN induction_records.end_date IS NULL
            THEN 1
          ELSE 2
        END,
        induction_records.start_date DESC,
        induction_records.created_at DESC
    SQL
  end
end
