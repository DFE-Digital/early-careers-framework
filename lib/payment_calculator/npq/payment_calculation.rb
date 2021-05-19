# frozen_string_literal: true

require "initialize_with_config"
require "payment_calculator/npq/service_fees"
require "payment_calculator/npq/output_payment"

module PaymentCalculator
  module Npq
    class PaymentCalculation
      include InitializeWithConfig

      def call
        {
          input: config.to_h,
          output: {
            service_fees: ::PaymentCalculator::Npq::ServiceFees.call(config),
            output_payment: ::PaymentCalculator::Npq::OutputPayment.call(config),
          },
        }
      end
    end
  end
end
