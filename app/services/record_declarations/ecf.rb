# frozen_string_literal: true

module RecordDeclarations
  module ECF
    extend ActiveSupport::Concern

    included do
      delegate :participant?, to: :user, allow_nil: true
    end

    def schema_validation_params
      super.merge({ schema_path: "ecf/participant_declarations" })
    end

    def declaration_type
      ParticipantDeclaration::ECF
    end

    def actual_lead_provider
      user_profile&.school_cohort&.lead_provider&.cpd_lead_provider
    end
  end
end
