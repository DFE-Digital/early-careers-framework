# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, participant_declaration: ParticipantDeclaration::ECF, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, participant_declaration: participant_declaration).call(event_type: event_type)
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

      attr_accessor :cpd_lead_provider, :participant_declaration

      def initialize(cpd_lead_provider:, participant_declaration: ParticipantDeclaration::ECF)
        self.cpd_lead_provider       = cpd_lead_provider
        self.participant_declaration = participant_declaration
      end
    end
  end
end
