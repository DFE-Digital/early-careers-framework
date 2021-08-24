# frozen_string_literal: true

require "participant_event_aggregator"
require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(cpd_lead_provider:,
             contract:,
             recorder: ParticipantDeclaration::ECF,
             calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
             event_type: :started)
      new(
        cpd_lead_provider: cpd_lead_provider,
        contract: contract,
        recorder: recorder,
        calculator: calculator,
      ).call(event_type: event_type)
    end
  end

  def call(event_type:)
    calculator.call(contract: contract, aggregations: aggregations(event_type: event_type), event_type: event_type)
  end

private

  attr_accessor :cpd_lead_provider, :contract, :recorder, :calculator

  def initialize(cpd_lead_provider:,
                 contract:,
                 recorder: ParticipantDeclaration::ECF,
                 calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
    @cpd_lead_provider = cpd_lead_provider
    @contract = contract
    @recorder = recorder
    @calculator = calculator
  end

  def aggregators(event_type:)
    @aggregators ||= Hash.new { |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type) }
  end

  def aggregate(aggregation_type:, event_type:)
    recorder.send(aggregation_types[event_type][aggregation_type], cpd_lead_provider).payable.count
  end

  def aggregation_types
    {
      started: {
        all: :active_for_lead_provider,
        uplift: :active_uplift_for_lead_provider,
        ects: :active_ects_for_lead_provider,
        mentors: :active_mentors_for_lead_provider,
      },
    }
  end

  def aggregations(event_type:)
    aggregation_types[event_type].keys.index_with do |key|
      aggregators(event_type: event_type)[key]
    end
  end
end
