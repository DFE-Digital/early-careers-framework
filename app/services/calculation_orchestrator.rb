# frozen_string_literal: true

require "participant_event_aggregator"
require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(cpd_lead_provider:,
             contract:,
             aggregator: ::ParticipantEventAggregator,
             calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
             event_type: :started)
      new(
        cpd_lead_provider: cpd_lead_provider,
        contract: contract,
        aggregator: aggregator,
        calculator: calculator
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
                 aggregator: ::ParticipantEventAggregator,
                 calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
    @cpd_lead_provider = cpd_lead_provider
    @contract = contract
    @aggregator = aggregator
    @calculator = calculator
  end

  def aggregators(event_type:)
    @cached_aggregator ||= Hash.new{ |hash, key| hash[key] = aggregate(aggregation_type: key, event_type: event_type) }
  end

  def aggregate(aggregation_type:, event_type:)
    aggregator.call({ cpd_lead_provider: cpd_lead_provider, event_type=>aggregation_types[event_type][aggregation_type] }, event_type: event_type)
  end

  def aggregation_types
    {
      started: {
        all: :count_active_for_lead_provider,
        uplift: :count_active_uplift_for_lead_provider,
        ects: :count_active_ects_for_lead_provider,
        mentors: :count_active_mentors_for_lead_provider,
      }
    }
  end

  def aggregations(event_type:)
    aggregation_types[event_type].keys.map do |key|
      [key, aggregators(event_type: event_type)[key]]
    end.to_h
  end

end
