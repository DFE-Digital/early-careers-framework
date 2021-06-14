# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

class ContractEventPaymentCalculator
  class << self
    def call(lead_provider:, total_participants:, event_type: :started, payment_calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
      new(lead_provider: lead_provider, payment_calculator: payment_calculator).call(total_participants: total_participants, event_type: event_type)
    end
  end

  # @param [Symbol] event_type
  # @param [Integer] total_participants
  # Call the payment_calculator class that performs the actual contracted calculation passing in the total number
  # of filtered participants and the event type
  # Instantiate with new(lead_provider: <#lead_provider_instance>) or pass that as the named parameter to the class level
  # call, e.g.
  #
  # ContractEventPaymentCalculator.call(lead_provider: <#lead_provider_instance>, total_participants: 2000, event_type: :started)
  #
  def call(total_participants:, event_type:)
    @payment_calculator.call(lead_provider: @lead_provider, total_participants: total_participants, event_type: event_type)
  end

private

  def initialize(lead_provider:, payment_calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
    @lead_provider = lead_provider
    @payment_calculator = payment_calculator
  end
end
