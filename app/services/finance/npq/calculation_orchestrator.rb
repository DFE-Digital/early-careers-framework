# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator
      class << self
        def call(npq_contract:, aggregator:, calculator:, interval:)
          new(aggregator: aggregator, calculator: calculator)
            .call(contract: npq_contract, interval: interval)
        end
      end

      def call(contract:, interval:)
        calculator
          .call(
            contract: contract,
            course_identifier: contract.course_identifier,
            aggregations: aggregations_for(contract: contract, interval: interval),
          )
      end

    private

      attr_accessor :cpd_lead_provider, :contract, :aggregator, :calculator

      def initialize(aggregator:, calculator:)
        self.aggregator        = aggregator
        self.calculator        = calculator
      end

      def aggregations_for(contract:, interval:)
        aggregator.call(
          cpd_lead_provider: contract.npq_lead_provider.cpd_lead_provider,
          course_identifier: contract.course_identifier,
          interval: interval,
        )
      end
    end
  end
end
