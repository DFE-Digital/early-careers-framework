# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, recorder: ParticipantDeclaration::NPQ, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type)
        end

        def aggregation_types
          {
            started: {
              not_yet_included: :not_eligible_for_lead_provider,
              all: :eligible_for_lead_provider,
            },
          }
        end
      end

    private

      attr_reader :cpd_lead_provider, :recorder

      def initialize(cpd_lead_provider:, recorder: ParticipantDeclaration::NPQ)
        @cpd_lead_provider = cpd_lead_provider
        @recorder = recorder
      end
    end
  end
end
