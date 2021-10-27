# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, recorder: ParticipantDeclaration::ECF, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, recorder: recorder).call(event_type: event_type)
        end

        def aggregation_types
          {
            started: {
              not_eligible: :not_eligible_for_lead_provider,
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

      def initialize(cpd_lead_provider:, recorder: ParticipantDeclaration::ECF)
        @cpd_lead_provider = cpd_lead_provider
        @recorder = recorder
      end
    end
  end
end
