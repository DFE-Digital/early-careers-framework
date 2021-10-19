# frozen_string_literal: true

module NPQ
  class StreamBigQueryEnrollmentJob < ApplicationJob
    def perform(npq_application_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_registration", skip_lookup: true
      table = dataset.table "enrollments_#{Rails.env.downcase}", skip_lookup: true
      npq_application = NPQApplication.find(npq_application_id)

      rows = [
        {
          "application_ecf_id" => npq_application.id,
          "status" => npq_application.lead_provider_approval_status,
          "updated_at" => npq_application.updated_at,
        },
      ]

      table.insert rows
    end
  end
end
