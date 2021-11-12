# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "abstract_interface"

module Finance
  class CalculationOrchestrator

    class << self
      def call(cpd_lead_provider:, contract:, aggregator:, calculator:)
        new(
          aggregator: aggregator,
          calculator: calculator,
        ).call(contract)
      end
    end

    def call
      calculator.call(
        contract: contract,
        aggregations: aggregations,
      )
    end

  private

    attr_accessor :cpd_lead_provider, :contract, :aggregator, :calculator

    def initialize(cpd_lead_provider:,
                   contract:,
                   aggregator: self.class.default_aggregator,
                   calculator: self.class.default_calculator)
      self.cpd_lead_provider = cpd_lead_provider
      self.contract          = contract
      self.aggregator        = aggregator
      self.calculator        = calculator
    end

    def aggregations
      aggregator.call(cpd_lead_provider: cpd_lead_provider, event_type: event_type)
    end
  end
end
