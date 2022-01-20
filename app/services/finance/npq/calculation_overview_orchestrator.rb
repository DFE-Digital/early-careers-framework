# frozen_string_literal: true

require "payment_calculator/npq/payment_calculation"

module Finance
  module NPQ
    class CalculationOverviewOrchestrator
      def call(event_type:)
        cpd_lead_provider.npq_lead_provider.npq_contracts.map do |contract|
          Finance::NPQ::CalculationOrchestrator.new(
            statement: statement,
            contract: contract,
            aggregator: aggregator,
          ).call(event_type: event_type)
        end
      end

    private

      attr_accessor :statement, :cpd_lead_provider, :calculation_orchestrator, :aggregator

      def initialize(statement:, aggregator:)
        self.statement                = statement
        self.cpd_lead_provider        = statement.cpd_lead_provider
        self.aggregator               = aggregator
      end
    end
  end
end
