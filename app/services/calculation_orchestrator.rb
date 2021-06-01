# frozen_string_literal: true

require "initialize_with_config"
require "participant_event_aggregator"
require "contract_event_payment_calculator"

class CalculationOrchestrator
  include InitializeWithConfig

  def call(event_type:)
    total_participants = aggregator.call(config, event_type: event_type)
    calculator.call(config, total_participants: total_participants, event_type: event_type)
  end

private

  def default_config
    {
      aggregator: ::ParticipantEventAggregator,
      calculator: ::ContractEventPaymentCalculator,
    }
  end
end
