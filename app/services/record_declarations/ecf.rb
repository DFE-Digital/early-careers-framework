# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    included do
      delegate :participant?, to: :user, allow_nil: true
    end

    def declaration_model
      ParticipantDeclaration::ECF
    end

    def actual_lead_provider
      user_profile&.school_cohort&.lead_provider&.cpd_lead_provider
    end

    def valid_declaration_types
      %w[started completed retained-1 retained-2 retained-3 retained-4]
    end
  end
end
