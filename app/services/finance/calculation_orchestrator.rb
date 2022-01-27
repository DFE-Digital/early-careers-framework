# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "abstract_interface"

module Finance
  class CalculationOrchestrator
    include AbstractInterface
    implement_class_method :default_aggregator, :default_calculator

    def call(event_type:)
      calculator.call(
        contract: contract,
        event_type: event_type,
        aggregations: aggregator.new(
          statement: statement,
        ).call(event_type: event_type),
      )
    end

  private

    attr_reader :statement, :contract, :aggregator, :calculator

    def initialize(statement:,
                   contract:,
                   aggregator: self.class.default_aggregator,
                   calculator: self.class.default_calculator)
      @statement = statement
      @contract = contract
      @aggregator = aggregator
      @calculator = calculator
    end
  end
end
