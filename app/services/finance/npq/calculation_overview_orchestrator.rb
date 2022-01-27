# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOverviewOrchestrator
      class << self
        def call(
          aggregator:,
          cpd_lead_provider:,
          calculation_orchestrator: ::Finance::NPQ::CalculationOrchestrator,
          event_type: :started,
          interval: nil
        )
          new(cpd_lead_provider: cpd_lead_provider, calculation_orchestrator: calculation_orchestrator, interval: interval, aggregator: aggregator)
            .call(event_type: event_type)
        end
      end

      def call(event_type:)
        cpd_lead_provider.npq_lead_provider.npq_contracts.map do |contract|
          calculation_orchestrator.call(
            event_type: event_type,
            cpd_lead_provider: cpd_lead_provider,
            contract: contract,
            interval: interval,
            aggregator: aggregator,
          )
        end
      end

    private

      attr_accessor :cpd_lead_provider, :calculation_orchestrator, :interval, :aggregator

      def initialize(cpd_lead_provider:, calculation_orchestrator:, interval:, aggregator:)
        self.cpd_lead_provider        = cpd_lead_provider
        self.calculation_orchestrator = calculation_orchestrator
        self.interval                 = interval
        self.aggregator               = aggregator
      end
    end
  end
end
