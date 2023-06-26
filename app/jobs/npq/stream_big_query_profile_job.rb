# frozen_string_literal: true

module NPQ
  class StreamBigQueryProfileJob < ApplicationJob
    queue_as :big_query

    def perform(profile_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_registration", skip_lookup: true
      table = dataset.table "profiles_#{Rails.env.downcase}"

      return if table.nil?

      profile = ParticipantProfile::NPQ
        .includes(:npq_application, :schedule, :npq_course, :participant_identity)
        .find(profile_id)

      rows = [
        {
          profile_id: profile.id,
          user_id: profile.participant_identity.user_id,
          external_id: profile.participant_identity.external_identifier,
          application_ecf_id: profile.npq_application&.id,
          status: profile.status,
          training_status: profile.training_status,
          schedule_identifier: profile.schedule&.schedule_identifier,
          course_identifier: profile.npq_course&.identifier,
          created_at: profile.created_at,
          updated_at: profile.updated_at,
        }.stringify_keys,
      ]

      table.insert(rows, ignore_unknown: true)
    end
  end
end
