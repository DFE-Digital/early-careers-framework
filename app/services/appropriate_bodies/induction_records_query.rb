# frozen_string_literal: true

module AppropriateBodies
  class InductionRecordsQuery
    attr_reader :appropriate_body

    def initialize(appropriate_body:)
      @appropriate_body = appropriate_body
    end

    def induction_records
      join = InductionRecord
        .select(Arel.sql("DISTINCT FIRST_VALUE(induction_records.id) OVER (#{latest_induction_record_order}) AS latest_id"))
        .joins(:participant_profile)
        .where(appropriate_body:)

      InductionRecord.distinct
        .joins("JOIN (#{join.to_sql}) AS latest_induction_records ON latest_induction_records.latest_id = induction_records.id")
        .includes(
          :induction_programme,
          :partnership,
          :lead_provider,
          :user,
          school: [:induction_coordinators],
          participant_profile: %i[teacher_profile ecf_participant_eligibility ecf_participant_validation_data],
        )
        .select(
          "induction_records.*",
          latest_email_status_per_participant,
          mentees_count,
          current_mentees_count,
        )
    end

  private

    def mentees_count
      <<~SQL
        EXISTS (
          SELECT 1 FROM induction_records as mir
            WHERE mir.mentor_profile_id = induction_records.participant_profile_id
          ) AS transient_mentees
      SQL
    end

    def current_mentees_count
      <<~SQL
        EXISTS (
          SELECT 1 FROM induction_records as cmir
            WHERE cmir.mentor_profile_id = induction_records.participant_profile_id
              AND (cmir.induction_status = 'active' OR cmir.induction_status = 'leaving')
          ) AS transient_current_mentees
      SQL
    end

    def latest_email_status_per_participant
      <<~SQL
        (
          SELECT
              e.status
          FROM
              emails e
          INNER JOIN
              email_associations ea ON e.id = ea.email_id
          WHERE
              'request_for_details' = ANY (e.tags)
          AND
              ea.object_type = 'ParticipantProfile'
          AND
              ea.object_id = induction_records.participant_profile_id
          ORDER BY
              e.created_at DESC
          LIMIT 1
        ) AS transient_latest_request_for_details_status
      SQL
    end

    def latest_induction_record_order
      <<~SQL
        PARTITION BY induction_records.participant_profile_id, induction_records.appropriate_body_id
          ORDER BY induction_records.created_at DESC
      SQL
    end
  end
end
