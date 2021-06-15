# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"

module PaymentCalculator
  module Ecf
    class OutputPaymentRetentionEvent
      include PaymentCalculator::Ecf::Contract::OutputPaymentCalculations

      def call(total_participants:, event_type:, band:)
        {
          retained_participants: total_participants,
          per_participant: output_payment_per_participant_for_event(event_type: event_type, band: band).round(0),
          subtotal: output_payment_for_event(total_participants: total_participants, event_type: event_type, band: band).round(0),
        }
      end
    end
  end
end
