# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "abstract_interface"

module Finance
  class CalculationOrchestrator
    class << self
      def call(cpd_lead_provider:, contract:, aggregator:, calculator:, event_type: :started)
        new(
          cpd_lead_provider: cpd_lead_provider,
          aggregator: aggregator,
          calculator: calculator,
          event_type: event_type,
        ).call(contract)
      end
    end

    def call(contract)
      calculator.call(
        contract: contract,
        aggregations: aggregations,
      )
    end

  private

    attr_accessor :cpd_lead_provider, :aggregator, :calculator, :event_type

    def initialize(cpd_lead_provider:, aggregator:, calculator:, event_type:)
      self.cpd_lead_provider = cpd_lead_provider
      self.aggregator        = aggregator
      self.calculator        = calculator
      self.event_type        = event_type
    end

    def aggregations
      aggregator.call(cpd_lead_provider: cpd_lead_provider)
    end
  end
end
