# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator < ::Finance::CalculationOrchestrator
      class << self
        def default_aggregator
          ::Finance::NPQ::ParticipantAggregator
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
            aggregations: aggregations_for(event_type: event_type),
          )
      end

    private

      def aggregations_for(event_type:)
        aggregator.new(
          statement: statement,
          course_identifier: contract.course_identifier,
        ).call(
          event_type: event_type,
        )
      end
    end
  end
end
