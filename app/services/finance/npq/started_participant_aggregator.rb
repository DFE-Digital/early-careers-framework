# frozen_string_literal: true

module Finance
  module NPQ
    class StartedParticipantAggregator < Finance::ParticipantAggregator
      class << self
        def call(cpd_lead_provider:, course_identifier:, participant_declaration: ParticipantDeclaration::NPQ, event_type: :started)
          new(cpd_lead_provider: cpd_lead_provider, participant_declaration: participant_declaration, course_identifier: course_identifier)
            .call(event_type: event_type)
        end

        def aggregation_types
          {
            started: {
              PaymentCalculator::NPQ::BreakdownSummary::ALL => :for_lead_provider_and_course,
              PaymentCalculator::NPQ::BreakdownSummary::SUBMITTED => :submitted_for_lead_provider_and_course,
              PaymentCalculator::NPQ::BreakdownSummary::ELIGIBLE_AND_PAYABLE => :eligible_and_payable_for_lead_provider_and_course,
            },
          }
        end
      end

    private

      attr_accessor :cpd_lead_provider, :participant_declaration, :course_identifier

      def initialize(cpd_lead_provider:, course_identifier:, participant_declaration: ParticipantDeclaration::NPQ)
        self.cpd_lead_provider       = cpd_lead_provider
        self.participant_declaration = participant_declaration
        self.course_identifier       = course_identifier
      end

      def aggregate(aggregation_type:, event_type:)
        participant_declaration.public_send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider, course_identifier).count
      end
    end
  end
end
