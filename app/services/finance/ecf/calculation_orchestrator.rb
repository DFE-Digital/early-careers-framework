# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

module Finance
  module ECF
    class CalculationOrchestrator < ::Finance::CalculationOrchestrator
      class << self
        def default_aggregator
          ::ParticipantAggregator
        end

        def default_calculator
          ::PaymentCalculator::ECF::PaymentCalculation
        end
      end
    end
  end
end
