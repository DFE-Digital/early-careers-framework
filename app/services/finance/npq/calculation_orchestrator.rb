# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator < Finance::CalculationOrchestrator
      class << self
        def default_aggregator
          ::Finance::NPQ::StartedParticipantAggregator
        end

        def default_calculator
          ::PaymentCalculator::NPQ::PaymentCalculation
        end
      end

      def call(event_type:)
        calculator
          .call(
            contract: contract,
            course_identifier: contract.course_identifier,
            aggregations: aggregations_for(event_type),
          )
      end

    private

      def aggregate(aggregation_type:, course_identifier:, event_type:)
        recorder.send(self.class.aggregation_types[event_type][aggregation_type], cpd_lead_provider, course_identifier).count
      end

      def aggregations_for(event_type)
        aggregator.call(
          cpd_lead_provider: cpd_lead_provider,
          event_type: event_type,
          course_identifier: contract.course_identifier,
        )
      end
    end
  end
end
