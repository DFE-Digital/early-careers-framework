# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator
      class << self
        def call(npq_contract:, aggregator:, calculator:)
          new(aggregator: aggregator, calculator: calculator).call(npq_contract)
        end
      end

      def call(npq_contract)
        calculator
          .call(
            contract: npq_contract,
            course_identifier: npq_contract.course_identifier,
            aggregations: aggregations_for(npq_contract),
          )
      end

    private

      attr_accessor :cpd_lead_provider, :contract, :aggregator, :calculator

      def initialize(aggregator:, calculator:)
        self.aggregator        = aggregator
        self.calculator        = calculator
      end

      def aggregations_for(npq_contract)
        aggregator.call(
          cpd_lead_provider: npq_contract.npq_lead_provider.cpd_lead_provider,
          course_identifier: npq_contract.course_identifier,
        )
      end
    end
  end
end
