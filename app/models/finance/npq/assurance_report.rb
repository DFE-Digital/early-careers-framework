# frozen_string_literal: true

module Finance
  module NPQ
    class AssuranceReport
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :participant_id
      attribute :participant_name
      attribute :trn
      attribute :course_identifier
      attribute :schedule
      attribute :eligible_for_funding, :boolean
      attribute :npq_lead_provider_name
      attribute :school_urn
      attribute :school_name
      attribute :training_status
      attribute :training_status_reason
      attribute :declaration_id
      attribute :declaration_status
      attribute :declaration_type
      attribute :declaration_date, :datetime
      attribute :declaration_created_at, :datetime
      attribute :statement_name
      attribute :statement_id

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
