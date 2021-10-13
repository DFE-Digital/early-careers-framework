# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(cpd_lead_provider:,
             contract:,
             aggregator: ::ParticipantEventPayableAggregator,
             calculator: ::PaymentCalculator::ECF::PaymentCalculation,
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

  attr_reader :cpd_lead_provider, :contract, :aggregator, :calculator

  def initialize(cpd_lead_provider:,
                 contract:,
                 aggregator: ::ParticipantEventAggregator,
                 calculator: ::PaymentCalculator::ECF::PaymentCalculation)
    @cpd_lead_provider = cpd_lead_provider
    @contract = contract
    @aggregator = aggregator
    @calculator = calculator
  end
end
