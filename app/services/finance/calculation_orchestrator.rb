# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"
require "abstract_interface"

module Finance
  class CalculationOrchestrator
    include AbstractInterface
    implement_class_method :default_aggregator, :default_calculator

    def call(event_type:)
      calculator.call(
        contract:,
        event_type:,
        aggregations: aggregator.call(event_type:),
      )
    end

  private

    attr_reader :statement, :contract, :aggregator, :calculator

    def initialize(statement:,
                   contract:,
                   aggregator: nil,
                   calculator: self.class.default_calculator)
      @statement = statement
      @contract = contract
      @aggregator = aggregator || default_aggregator
      @calculator = calculator
    end

    def default_aggregator
      self.class.default_aggregator.new(statement:)
    end
  end
end
