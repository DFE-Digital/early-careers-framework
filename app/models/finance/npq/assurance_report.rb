# frozen_string_literal: true

module Finance
  module NPQ
    class AssuranceReport < ApplicationRecord
      self.table_name = "npq_assurance_reports"

      def to_csv
        [
          participant_id,
          participant_name,
          trn,
          course_identifier,
          schedule,
          eligible_for_funding,
          npq_lead_provider_name,
          school_urn,
          school_name,
          training_status,
          training_status_reason,
          declaration_id,
          declaration_status,
          declaration_type,
          declaration_date.iso8601,
          declaration_created_at.iso8601,
          statement_name,
          statement_id,
        ]
      end
    end
  end
end
