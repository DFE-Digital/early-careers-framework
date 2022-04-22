# frozen_string_literal: true

module PaymentCalculator
  module ECF
    class OutputPaymentCalculator
      include HasDIParameters

      delegate :bands, to: :contract

      def call(event_type:, total_participants:, total_previous_participants:)
        bands.each_with_index.map do |band, i|
          {
            band: i,
            participants: band.number_of_participants_in_this_band(total_participants, total_previous_participants),
            per_participant: output_payment_per_participant_for_event(event_type: event_type, band: band),
            subtotal: output_payment_for_event(
              total_participants: total_participants,
              total_previous_participants: total_previous_participants,
              event_type: event_type,
              band: band,
            ),
          }
        end
      end

      def output_payment_for_event(event_type:, total_participants:, total_previous_participants:, band:)
        band.number_of_participants_in_this_band(total_participants, total_previous_participants) * output_payment_per_participant_for_event(event_type: event_type, band: band)
      end

      def output_payment_per_participant_for_event(event_type:, band:)
        event_type = event_type.parameterize.underscore.intern if event_type.is_a?(String)
        send(event_type) * band.output_payment_per_participant
      end

    private

      def start_and_completion_event_percentage
        0.2
      end

      alias_method :started, :start_and_completion_event_percentage
      alias_method :completion, :start_and_completion_event_percentage # DEPRECATE
      alias_method :completed, :start_and_completion_event_percentage

      def interim_retained_period_event_percentage
        0.15
      end

      alias_method :retained_1, :interim_retained_period_event_percentage
      alias_method :retained_2, :interim_retained_period_event_percentage
      alias_method :retained_3, :interim_retained_period_event_percentage
      alias_method :retained_4, :interim_retained_period_event_percentage
    end
  end
end
