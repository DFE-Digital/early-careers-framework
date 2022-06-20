# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class OutputPayment
      class << self
        def call(contract:, total_participants:)
          new(contract:).call(total_participants:)
        end
      end

      def call(total_participants:)
        {
          participants: total_participants,
          per_participant: milestone_output_payments,
          subtotal: total_participants * milestone_output_payments,
        }
      end

    private

      attr_reader :contract

      delegate :per_participant, :output_payment_percentage, :number_of_payment_periods, to: :contract

      def initialize(contract:)
        @contract = contract
      end

      def milestone_output_payments
        return 0 if output_payment_percentage.zero?

        per_participant * output_payment_percentage / (100 * number_of_payment_periods)
      end
    end
  end
end
