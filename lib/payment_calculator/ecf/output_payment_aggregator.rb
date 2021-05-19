# frozen_string_literal: true
require_relative 'output_payment_per_participant'
require_relative 'output_payment_schedule'

module PaymentCalculator
  module Ecf
    class OutputPaymentAggregator
      include InitializeWithConfig
      delegate :retained_participants, to: :config

      def call
        {
          per_participant: ::PaymentCalculator::Ecf::OutputPaymentPerParticipant.call(config),
          **({ output_payment_schedule: ::PaymentCalculator::Ecf::OutputPaymentSchedule.call(config) } if retained_participants).to_h,
        }
      end
    end
  end
end
