# frozen_string_literal: true

require "initialize_with_config"
require "payment_calculator/ecf/service_fees"
require "payment_calculator/ecf/output_payment_aggregator"

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
