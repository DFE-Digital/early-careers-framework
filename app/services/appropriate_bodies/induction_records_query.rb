# frozen_string_literal: true

module AppropriateBodies
  class InductionRecordsQuery
    include Api::Concerns::TrainingRecordStateOptimizable

    attr_reader :appropriate_body

    def initialize(appropriate_body:)
      @appropriate_body = appropriate_body
    end

    def induction_records
      join = InductionRecord
        .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
        .joins(:participant_profile)
        .where(appropriate_body:, participant_profile: { type: ParticipantProfile::ECT })

      InductionRecord.distinct
        .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
        .includes(
          :user,
          :cohort,
          school: %i[induction_coordinators],
          induction_programme: { partnership: %i[lead_provider] },
          participant_profile: %i[teacher_profile ecf_participant_eligibility ecf_participant_validation_data],
        )
        .where(cohort: { start_year: Cohort.active_registration_cohort.start_year })
        .select(
          "induction_records.*",
          latest_email_status_per_participant,
        )
    end

  private

    def latest_induction_record_order
      <<~SQL
        PARTITION BY induction_records.participant_profile_id, induction_records.appropriate_body_id
          ORDER BY induction_records.created_at DESC
      SQL
    end
  end
end
