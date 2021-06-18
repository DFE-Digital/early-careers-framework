# frozen_string_literal: true

require "payment_calculator/ecf/contract/uplift_payment_calculations"
require "payment_calculator/ecf/output_payment_retention_event"

module PaymentCalculator
  module Ecf
    class UpliftPaymentAggregator
      include Contract::UpliftPaymentCalculations

      def call(total_participants:)
        {
          per_participant: 100.to_d,
          total: total_participants,
        }
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
