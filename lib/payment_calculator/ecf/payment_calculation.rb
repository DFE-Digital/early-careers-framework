# frozen_string_literal: true

module PaymentCalculator
  module Ecf
    class PaymentCalculation
      include InitializeWithConfig

      def call
        {
          input: config.to_h,
          output: {
            service_fees: ServiceFees.call(config),
            output_payment: OutputPaymentAggregator.call(config),
          },
        }
      end
    end
  end
end
