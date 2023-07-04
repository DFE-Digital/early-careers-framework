# frozen_string_literal: true

module AppropriateBodies
  class InductionRecordsQuery
    attr_reader :appropriate_body

    def initialize(appropriate_body:)
      @appropriate_body = appropriate_body
    end

    def induction_records
      join = InductionRecord
        .select("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id")
        .joins(:participant_profile, :appropriate_body, induction_programme: :partnership)
        .where(
          induction_programme: {
            partnerships: {
              challenged_at: nil,
              challenge_reason: nil,
              pending: false,
            },
          },
        )

      InductionRecord.distinct
        .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
        .where(appropriate_body:)
    end

  private

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
end
