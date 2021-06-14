# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"
require "payment_calculator/ecf/output_payment_retention_event"

module PaymentCalculator
  module Ecf
    class OutputPaymentAggregator
      include Contract::OutputPaymentCalculations

      delegate :bands, to: :contract

      # @param [Symbol] event_type
      # @param [Integer] total_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(event_type:, total_participants:)
        bands.map do |band|
          {
            per_participant: output_payment_per_participant(band).round(0),
            event_type => output_payment_retention_event.call(
              params, event_type: event_type, total_participants: total_participants, band: band
            ),
          }
        end
      end

    private

      def default_params
        {
          output_payment_retention_event: PaymentCalculator::Ecf::OutputPaymentRetentionEvent,
        }
      end
    end
  end
end
