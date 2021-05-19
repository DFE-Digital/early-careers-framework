# frozen_string_literal: true

module PaymentCalculator
  module Ecf
    class OutputPaymentAggregator
      include InitializeWithConfig
      delegate :retained_participants, to: :config

      def call
        {
          per_participant: OutputPaymentPerParticipant.call(config),
          **({ output_payment_schedule: OutputPaymentSchedule.call(config) } if retained_participants).to_h,
        }
      end
    end
  end
end
