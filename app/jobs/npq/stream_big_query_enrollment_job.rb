# frozen_string_literal: true

module NPQ
  class StreamBigQueryEnrollmentJob < ApplicationJob
    def perform(npq_validation_data_id:)
      bigquery = Google::Cloud::Bigquery.new
      dataset = bigquery.dataset "npq_registration", skip_lookup: true
      table = dataset.table "enrollments_#{Rails.env.downcase}", skip_lookup: true
      npq_validation_data = NPQValidationData.find(npq_validation_data_id)

      rows = [
        {
          "application_ecf_id" => npq_validation_data.id,
          "status" => npq_validation_data.lead_provider_approval_status,
          "updated_at" => npq_validation_data.updated_at,
        },
      ]

      table.insert rows
    end
  end
end
