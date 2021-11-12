# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOverviewOrchestrator
      class << self
        def call(cpd_lead_provider:, calculation_orchestrator: ::Finance::NPQ::CalculationOrchestrator)
          new(
            cpd_lead_provider: cpd_lead_provider,
            calculation_orchestrator: calculation_orchestrator,
          ).call
        end
      end

      def call
        cpd_lead_provider.npq_lead_provider.npq_contracts.map do |contract|
          calculation_orchestrator.call(contract)
        end
      end

    private

      attr_accessor :cpd_lead_provider, :calculation_orchestrator

      def initialize(cpd_lead_provider:, calculation_orchestrator: )
        self.cpd_lead_provider        = cpd_lead_provider
        self.calculation_orchestrator = calculation_orchestrator
      end
    end
  end
end
