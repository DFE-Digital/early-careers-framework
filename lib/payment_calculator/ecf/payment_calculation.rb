# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"
require "payment_calculator/ecf/output_payment_aggregator"
require "payment_calculator/ecf/uplift_calculation"

module PaymentCalculator
  module Ecf
    class PaymentCalculation
      class << self
        def call(contract:,
                 service_fee_calculator: ::PaymentCalculator::Ecf::ServiceFees,
                 output_payment_aggregator: ::PaymentCalculator::Ecf::OutputPaymentAggregator,
                 uplift_payment_calculator: ::PaymentCalculator::Ecf::UpliftCalculation,
                 total_participants: 0,
                 uplift_participants: 0,
                 event_type: :started)
          new(
            contract: contract,
            service_fee_calculator: service_fee_calculator,
            output_payment_aggregator: output_payment_aggregator,
            uplift_payment_calculator: uplift_payment_calculator,
          ).call(total_participants: total_participants,
                 uplift_participants: uplift_participants,
                 event_type: event_type)
        end
      end

      def call(total_participants: 0,
               uplift_participants: 0,
               event_type: :started)
        {
          service_fees: @service_fee_calculator.call({ contract: @contract }),
          output_payments: @output_payment_aggregator.call({ contract: @contract }, event_type: event_type, total_participants: total_participants),
          uplift: @uplift_payment_calculator.call({ contract: @contract }, event_type: event_type, uplift_participants: uplift_participants),
        }
      end

    private

      def initialize(contract:,
                     service_fee_calculator: ::PaymentCalculator::Ecf::ServiceFees,
                     output_payment_aggregator: ::PaymentCalculator::Ecf::OutputPaymentAggregator,
                     uplift_payment_calculator: ::PaymentCalculator::Ecf::UpliftCalculation)
        @contract = contract
        @service_fee_calculator = service_fee_calculator
        @output_payment_aggregator = output_payment_aggregator
        @uplift_payment_calculator = uplift_payment_calculator
      end
    end
  end
end
