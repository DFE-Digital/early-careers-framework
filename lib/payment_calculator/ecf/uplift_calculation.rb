# frozen_string_literal: true

require "initialize_with_config"

module PaymentCalculator
  module Ecf
    class UpliftCalculation
      include Ecf::Contract::UpliftPaymentCalculations

      # @param [Symbol] event_type
      # @param [Integer] total_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(total_participants: 0, event_type: :started)
        return nil unless event_type == :started

        config[:contract] ||= lead_provider.call_off_contract
        {
          per_participant: uplift_payment_per_participant,
          monthly: uplift_payment_for_event(event_type: event_type, total_participants: total_participants),
        }
      end
    end
  end
end
