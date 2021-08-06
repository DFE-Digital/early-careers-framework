# frozen_string_literal: true

require "payment_calculator/ecf/contract/uplift_payment_calculations"

module PaymentCalculator
  module Ecf
    class UpliftCalculation
      include Ecf::Contract::UpliftPaymentCalculations

      # @param [Symbol] event_type
      # @param [Integer] uplift_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(uplift_participants: 0, event_type: :started)
        return nil unless event_type == :started

        {
          uplift: {
            participants: uplift_participants,
            per_participant: uplift_payment_per_participant,
            subtotal: uplift_payment_for_event(event_type: event_type, uplift_participants: uplift_participants),
          },
        }
      end
    end
  end
end
