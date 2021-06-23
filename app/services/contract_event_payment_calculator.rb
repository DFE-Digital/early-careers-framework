# frozen_string_literal: true

require "payment_calculator/ecf/payment_calculation"

class ContractEventPaymentCalculator
  class << self
    def call(contract:, total_participants:, uplift_participants:, event_type: :started, payment_calculator: ::PaymentCalculator::Ecf::PaymentCalculation)
      payment_calculator.call(contract: contract, total_participants: total_participants, uplift_participants: uplift_participants, event_type: event_type)
    end
  end
end
