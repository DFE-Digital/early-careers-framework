# frozen_string_literal: true

require "payment_calculator/ecf/contract/output_payment_calculations"

module PaymentCalculator
  module ECF
    class OutputPaymentAggregator
      include PaymentCalculator::ECF::Contract::OutputPaymentCalculations

      delegate :bands, to: :contract

      # @param [Symbol] event_type
      # @param [Integer] total_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(event_type:, total_participants:)
        bands.each_with_index.map do |band, i|
          {
            band: i,
            participants: band.number_of_participants_in_this_band(total_participants),
            per_participant: output_payment_per_participant_for_event(event_type: event_type, band: band),
            subtotal: output_payment_for_event(total_participants: total_participants, event_type: event_type, band: band),
          }
        end
      end
    end
  end
end
