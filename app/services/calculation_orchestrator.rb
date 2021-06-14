# frozen_string_literal: true

require "participant_event_aggregator"
require "contract_event_payment_calculator"

class CalculationOrchestrator
  class << self
    def call(lead_provider:, aggregator: ::ParticipantEventAggregator, calculator: ::ContractEventPaymentCalculator, event_type: :started)
      new(lead_provider: lead_provider, aggregator: aggregator, calculator: calculator).call(event_type: event_type)
    end
  end

  def call(event_type:)
    total_participants = @aggregator.call({ lead_provider: @lead_provider }, event_type: event_type)
    @calculator.call(lead_provider: @lead_provider, total_participants: total_participants, event_type: event_type)
  end

private

  def initialize(lead_provider:, aggregator: ::ParticipantEventAggregator, calculator: ::ContractEventPaymentCalculator)
    @lead_provider = lead_provider
    @aggregator = aggregator
    @calculator = calculator
  end
end
