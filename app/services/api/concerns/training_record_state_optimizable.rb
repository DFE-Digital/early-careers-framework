# frozen_string_literal: true

module Api::Concerns::TrainingRecordStateOptimizable
  extend ActiveSupport::Concern

protected

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
end
