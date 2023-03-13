# frozen_string_literal: true

module NPQ
  class StreamBigQueryEnrollmentJob < ApplicationJob
    queue_as :big_query

    def perform(npq_application_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_registration", skip_lookup: true
      table = dataset.table "enrollments_#{Rails.env.downcase}", skip_lookup: true
      npq_application = NPQApplication.find(npq_application_id)

      rows = [
        {
          "application_ecf_id" => npq_application.id,
          "cohort_id" => npq_application.cohort_id,
          "status" => npq_application.lead_provider_approval_status,
          "updated_at" => npq_application.updated_at,
          "employer_name" => npq_application.employer_name,
          "employment_role" => npq_application.employment_role,
        },
      ]

      table.insert(rows, ignore_unknown: true)
    end
  end
end
