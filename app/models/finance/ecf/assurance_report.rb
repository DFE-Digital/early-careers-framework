# frozen_string_literal: true

module Finance
  module ECF
    class AssuranceReport < ApplicationRecord
      self.table_name = "ecf_assurance_reports"

      def to_csv
        [
          participant_id,
          participant_name,
          trn,
          participant_type,
          mentor_profile_id,
          schedule,
          eligible_for_funding,
          eligible_for_funding_reason,
          sparsity_uplift,
          pupil_premium_uplift,
          sparsity_and_pp,
          lead_provider_name,
          delivery_partner_name,
          school_urn,
          school_name,
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
