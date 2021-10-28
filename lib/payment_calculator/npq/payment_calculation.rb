# frozen_string_literal: true

require "payment_calculator/npq/breakdown_summary"
require "payment_calculator/npq/service_fees"
require "payment_calculator/npq/output_payment"

module PaymentCalculator
  module NPQ
    class PaymentCalculation
      class << self
        def call(contract:,
                 breakdown_summary_compiler: BreakdownSummary,
                 service_fee_calculator: ServiceFees,
                 output_payment_calculator: OutputPayment,
                 aggregations: empty_aggregations)
          new(
            contract: contract,
            headings_calculator: breakdown_summary_compiler,
            service_fee_calculator: service_fee_calculator,
            output_payment_calculator: output_payment_calculator,
          ).call(aggregations: aggregations)
        end

      private

        def empty_aggregations
          { all: 0, not_yet_included: 0 }
        end
      end

      def call(aggregations:)
        {
          breakdown_summary: headings_calculator.call(contract: contract, aggregations: aggregations),
          service_fees: service_fee_calculator.call(contract: contract),
          output_payments: output_payment_calculator.call(contract: contract, total_participants: aggregations[:all]),
        }
      end

    private

      attr_accessor :contract, :service_fee_calculator, :headings_calculator, :output_payment_calculator

      def initialize(contract:,
                     headings_calculator: BreakdownSummary,
                     output_payment_calculator: OutputPayment,
                     service_fee_calculator: ServiceFees)
        @contract = contract
        @headings_calculator = headings_calculator
        @output_payment_calculator = output_payment_calculator
        @service_fee_calculator = service_fee_calculator
      end
    end
  end
end
