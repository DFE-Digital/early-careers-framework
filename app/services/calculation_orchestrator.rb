# frozen_string_literal: true

require "participant_event_aggregator"
require "payment_calculator/ecf/payment_calculation"

class CalculationOrchestrator
  class << self
    def call(lead_provider:,
             contract:,
             aggregator: ::ParticipantEventAggregator,
             # TODO: Add in aggregator for Uplift as uplift_aggregator: ::ParticipantUpliftAggregator (for example)
             # This is currently defined in Jira as https://dfedigital.atlassian.net/browse/CPDTP-195
             calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
             event_type: :started)
      total_participants = aggregator.call({ lead_provider: lead_provider }, event_type: event_type)
      uplift_participants = total_participants / 3 # Temporary code to fake the 33% target which will be removed when the aggregation is pulled in.
      # This is currently defined in Jira as https://dfedigital.atlassian.net/browse/CPDTP-195
      # TODO: uplift_participants = uplift_aggregator.call(leod_provider: event_type:) etc..
      calculator.call(contract: contract, total_participants: total_participants, uplift_participants: uplift_participants, event_type: event_type)
    end
  end
end
