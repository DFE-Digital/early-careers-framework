# frozen_string_literal: true

module Finance
  module NPQ
    class ParticipantEligibleAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, course_identifier:, recorder: ParticipantDeclaration::NPQ, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, recorder: recorder, course_identifier: course_identifier)
            .call(event_type: event_type)
        end

        def aggregation_types
          {
            started: {
              not_payed: :submitted_for_lead_provider_and_course,
              all: :eligible_for_lead_provider_and_course,
            },
          }
        end
      end

    private

      attr_reader :cpd_lead_provider, :recorder, :course_identifier

      def initialize(cpd_lead_provider:, course_identifier:, recorder: ParticipantDeclaration::NPQ)
        @cpd_lead_provider = cpd_lead_provider
        @recorder = recorder
        @course_identifier = course_identifier
      end

      def aggregate(aggregation_type:, event_type:)
        recorder.send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider, course_identifier).count
      end
    end
  end
end
