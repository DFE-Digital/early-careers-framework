# frozen_string_literal: true

require "initialize_with_config"
require "payment_calculator/ecf/payment_calculation"

class ContractEventPaymentCalculator
  include InitializeWithConfig

  # @param [Symbol] event_type
  # @param [Integer] total_participants
  # Call the payment_calculator class that performs the actual contracted calculation passing in the total number
  # of filtered participants and the event type
  # Instantiate with new({contract: CallOffContract.xxx}) or pass that as the first parameter to the class level
  # call, e.g.
  #
  # ContractEventPaymentCalculator.call({contract: CallOffContract.first}, total_participants: 2000, event_type: :started)
  #
  # A default is set, but only returns the first created contract.
  #
  # #contract must respond to :recruitment_target, :set_up_fee and :band_a, where #band_a also responds to
  # :per_participant
  def call(total_participants:, event_type:)
    payment_calculator.call(config, total_participants: total_participants, event_type: event_type)
  end

  def default_config
    {
      payment_calculator: ::PaymentCalculator::Ecf::PaymentCalculation,
    }
  end
end
