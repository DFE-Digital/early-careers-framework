# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(cpd_lead_provider:,
             contract:,
             aggregator: ParticipantDeclaration::ECF,
             calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
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
    calculator.call(contract: contract, aggregations: aggregations(event_type: event_type), event_type: event_type)
  end

private

  attr_accessor :cpd_lead_provider, :contract, :aggregator, :calculator

  def initialize(cpd_lead_provider:,
                 contract:,
                 aggregator: ParticipantDeclaration::ECF,
                 calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
    @cpd_lead_provider = cpd_lead_provider
    @contract = contract
    @aggregator = aggregator
    @calculator = calculator
  end

  def aggregators(event_type:)
    @aggregators ||= Hash.new { |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type) }
  end

  def aggregate(aggregation_type:, event_type:)
    aggregator.send(aggregation_types[event_type][aggregation_type], cpd_lead_provider).count
  end

  def aggregation_types
    {
      started: {
        all: :payable_for_lead_provider,
        uplift: :payable_uplift_for_lead_provider,
        ects: :payable_ects_for_lead_provider,
        mentors: :payable_mentors_for_lead_provider,
      },
    }
  end

  def aggregations(event_type:)
    aggregation_types[event_type].keys.index_with do |key|
      aggregators(event_type: event_type)[key]
    end
  end
end
