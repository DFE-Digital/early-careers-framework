# frozen_string_literal: true
require_relative 'service_fees'
require_relative 'output_payment_aggregator'

module PaymentCalculator
  module Ecf
    class PaymentCalculation
      include InitializeWithConfig

      def call
        {
          input: config.to_h,
          output: {
            service_fees: ::PaymentCalculator::Ecf::ServiceFees.call(config),
            output_payment: ::PaymentCalculator::Ecf::OutputPaymentAggregator.call(config),
          },
        }
      end
    end
  end
end
