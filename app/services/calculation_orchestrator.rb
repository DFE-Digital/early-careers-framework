# frozen_string_literal: true

require "participant_event_aggregator"
require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(lead_provider:,
             contract:,
             aggregator: ::ParticipantEventAggregator,
             uplift_aggregator: ::ParticipantUpliftAggregator,
             calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
             event_type: :started)
      total_participants = aggregator.call({ lead_provider: lead_provider }, event_type: event_type)
      uplift_participants = uplift_aggregator.call({ lead_provider: lead_provider }, event_type: event_type)
      calculator.call(contract: contract, total_participants: total_participants, uplift_participants: uplift_participants, event_type: event_type)
    end
  end
end
