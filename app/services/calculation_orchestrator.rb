# frozen_string_literal: true

require "has_di_parameters"
require "participant_event_aggregator"
require "contract_event_payment_calculator"

class CalculationOrchestrator
  include HasDIParameters

  def call(event_type:)
    total_participants = aggregator.call(params, event_type: event_type)
    calculator.call(params, total_participants: total_participants, event_type: event_type)
  end

private

  def default_params
    {
      aggregator: ::ParticipantEventAggregator,
      calculator: ::ContractEventPaymentCalculator,
    }
  end
end
