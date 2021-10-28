# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, participant_declarationant_declaration: ParticipantDeclaration::ECF, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, recorder: participant_declaration).call(event_type: event_type)
        end

        def aggregation_types
          {
            started: {
              not_yet_included: :not_eligible_for_lead_provider,
              all: :eligible_for_lead_provider,
              uplift: :eligible_uplift_for_lead_provider,
              ects: :eligible_ects_for_lead_provider,
              mentors: :eligible_mentors_for_lead_provider,
            },
          }
        end
      end

    private

      attr_reader :cpd_lead_provider, :recorder

      def initialize(cpd_lead_provider:, participant_declarationant_declaration: ParticipantDeclaration::ECF)
        @cpd_lead_provider = cpd_lead_provider
        @recorder = participant_declaration
      end
    end
  end
end
