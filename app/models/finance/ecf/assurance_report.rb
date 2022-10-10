# frozen_string_literal: true

module Finance
  module ECF
    class AssuranceReport
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :participant_id
      attribute :participant_name
      attribute :trn
      attribute :participant_type
      attribute :mentor_profile_id
      attribute :schedule
      attribute :eligible_for_funding, :boolean
      attribute :eligible_for_funding_reason
      attribute :sparsity_uplift, :boolean
      attribute :pupil_premium_uplift, :boolean
      attribute :sparsity_and_pp, :boolean
      attribute :lead_provider_name
      attribute :delivery_partner_name
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
