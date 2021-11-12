# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOrchestrator < Finance::CalculationOrchestrator
      def initialize(aggregator:, calculator:)
        self.aggregator        = aggregator
        self.calculator        = calculator
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

      attr_accessor :aggregator, :calculator

      # def aggregate(aggregation_type:, course_identifier:)
      #   recorder.send(self.class.aggregation_types[aggregation_type], cpd_lead_provider, course_identifier).count
      # end

      def aggregations_for(npq_contract)
        aggregator.call(
          cpd_lead_provider: cpd_lead_provider,
          course_identifier: npq_contract.course_identifier,
        )
      end
    end
  end
end
