# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOverviewOrchestrator
      class << self
        def call(cpd_lead_provider:, event_type:, calculation_orchestrator: ::Finance::NPQ::CalculationOrchestrator)
          new(cpd_lead_provider: cpd_lead_provider, calculation_orchestrator: calculation_orchestrator).call(event_type: event_type)
        end
      end

      def call(event_type:)
        cpd_lead_provider.npq_lead_provider.npq_contracts.map do |contract|
          calculation_orchestrator.call(
            cpd_lead_provider: cpd_lead_provider,
            contract: contract,
            event_type: event_type,
          )
        end
      end

    private

      attr_reader :cpd_lead_provider, :calculation_orchestrator

      def initialize(cpd_lead_provider:, calculation_orchestrator: ::Finance::NPQ::CalculationOrchestrator)
        @cpd_lead_provider = cpd_lead_provider
        @calculation_orchestrator = calculation_orchestrator
      end
    end
  end
end
