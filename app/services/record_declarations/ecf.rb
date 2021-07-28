# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    included do
      delegate :participant?, to: :user, allow_nil: true
    end

    def declaration_type
      ParticipantDeclaration::ECF
    end

    def actual_lead_provider
      user_profile&.school_cohort&.lead_provider&.cpd_lead_provider
    end
  end
end
