# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "abstract_interface"

module Finance
  class CalculationOrchestrator
    include AbstractInterface
    implement_class_method :default_aggregator, :default_calculator

    class << self
      def call(cpd_lead_provider:,
               contract:,
               aggregator: default_aggregator,
               calculator: default_calculator,
               event_type: :started)
        new(
          cpd_lead_provider: cpd_lead_provider,
          contract: contract,
          aggregator: aggregator,
          calculator: calculator,
        ).call(event_type: event_type)
      end
    end

    def call(event_type:)
      calculator.call(contract: contract, aggregations: aggregator.call(cpd_lead_provider: cpd_lead_provider, event_type: event_type), event_type: event_type)
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
  end
end
