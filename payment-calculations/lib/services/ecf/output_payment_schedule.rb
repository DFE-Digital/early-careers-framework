# frozen_string_literal: true

module Services
  module Ecf
    class OutputPaymentSchedule
      include InitializeWithConfig
      delegate :retained_participants, to: :config

      def call
        output_payment_schedule
      end

    private

      def output_payment_schedule
        retained_participants.each_with_object({}) do |(payment_type, number_retained), result|
          result[payment_type] = {
            retained_participants: number_retained,
            per_participant: output_payment_per_participant_for(payment_type),
            subtotal: output_payment_subtotal_for(payment_type, number_retained),
          }
        end
      end

      def output_payment_per_participant_for(payment_type)
        output_payment_per_participant * (payment_type.match(/Start|Completion/) ? 0.2 : 0.15)
      end

      def output_payment_subtotal_for(payment_type, number_retained)
        output_payment_per_participant_for(payment_type) * number_retained
      end

      def output_payment_per_participant
        OutputPaymentPerParticipant.call(config)
      end
    end
  end
end
