# frozen_string_literal: true

module DeliveryPartners
  class InductionRecordsQuery
    include Api::Concerns::TrainingRecordStateOptimizable

    attr_reader :delivery_partner

    def initialize(delivery_partner:)
      @delivery_partner = delivery_partner
    end

    def induction_records
      join = InductionRecord
        .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
        .includes(induction_programme: :partnership)
        .joins(:participant_profile)

      InductionRecord.distinct
        .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
        .includes(
          :lead_provider,
          :cohort,
          :preferred_identity,
          :school,
          user: :teacher_profile,
          induction_programme: [partnership: :lead_provider],
          participant_profile: %i[teacher_profile ecf_participant_eligibility ecf_participant_validation_data],
        )
        .select(
          "induction_records.*",
          latest_email_status_per_participant,
          mentees_count,
          current_mentees_count,
        )
        .where(
          induction_programmes: {
            partnerships: {
              delivery_partner:,
              challenged_at: nil,
              challenge_reason: nil,
              pending: false,
            },
          },
        )
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
