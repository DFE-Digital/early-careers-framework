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
               interval: nil,
               aggregator: default_aggregator,
               calculator: default_calculator,
               event_type: :started)
        new(
          cpd_lead_provider: cpd_lead_provider,
          contract: contract,
          aggregator: aggregator,
          calculator: calculator,
          interval: interval,
        ).call(event_type: event_type)
      end
    end

    def call(event_type:)
      calculator.call(
        contract: contract,
        event_type: event_type,
        aggregations: aggregator.call(cpd_lead_provider: cpd_lead_provider, event_type: event_type, interval: interval),
      )
    end

  private

    attr_reader :cpd_lead_provider, :contract, :aggregator, :calculator, :interval

    def initialize(cpd_lead_provider:,
                   contract:,
                   interval: nil,
                   aggregator: self.class.default_aggregator,
                   calculator: self.class.default_calculator)
      @cpd_lead_provider = cpd_lead_provider
      @contract = contract
      @aggregator = aggregator
      @calculator = calculator
      @interval = interval
    end
  end
end
