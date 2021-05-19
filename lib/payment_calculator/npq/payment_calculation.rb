# frozen_string_literal: true

module PaymentCalculator
  module Npq
    class PaymentCalculation
      include InitializeWithConfig

      def call
        {
          input: config.to_h,
          output: {
            service_fees: ServiceFees.call(config),
            output_payment: OutputPayment.call(config),
          },
        }
      end
    end
  end
end
