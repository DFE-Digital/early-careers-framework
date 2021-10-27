# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator < Finance::CalculationOrchestrator
      class << self
        def default_aggregator
          ::Finance::NPQ::ParticipantEventAggregator
        end

        def default_calculator
          ::PaymentCalculator::NPQ::PaymentCalculation
        end
      end

      def call(event_type:)
        calculator.call(contract: contract, aggregations: aggregator.call(cpd_lead_provider: cpd_lead_provider, event_type: event_type))
      end
    end
  end
end
