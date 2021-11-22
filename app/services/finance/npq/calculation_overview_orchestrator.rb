# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOverviewOrchestrator
      class << self
        def call(cpd_lead_provider:, calculation_orchestrator:, interval:)
          new(calculation_orchestrator)
            .call(cpd_lead_provider: cpd_lead_provider, interval: interval)
        end
      end

      def call(cpd_lead_provider:, interval:)
        cpd_lead_provider.npq_lead_provider.npq_contracts.map do |contract|
          calculation_orchestrator.call(contract: contract, interval: interval)
        end
      end

    private

      attr_accessor :calculation_orchestrator

      def initialize(calculation_orchestrator)
        self.calculation_orchestrator = calculation_orchestrator
      end
    end
  end
end
