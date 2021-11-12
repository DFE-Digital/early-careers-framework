# frozen_string_literal: true

require "payment_calculator/npq/breakdown_summary"
require "payment_calculator/npq/service_fees"
require "payment_calculator/npq/output_payment"

module PaymentCalculator
  module NPQ
    class PaymentCalculation
      class << self
        def call(contract:,
                 course_identifier:,
                 aggregations:,
                 breakdown_summary_calculator: BreakdownSummary,
                 service_fee_calculator: ServiceFees,
                 output_payment_calculator: OutputPayment)
          new(
            contract: contract,
            course_identifier: course_identifier,
            breakdown_summary_calculator: breakdown_summary_calculator,
            service_fee_calculator: service_fee_calculator,
            output_payment_calculator: output_payment_calculator,
          ).call(aggregations: aggregations)
        end
      end

      def call(aggregations:)
        pp aggregations
        {
          breakdown_summary: breakdown_summart_calculator.call(contract: contract, aggregations: aggregations),
          service_fees: service_fee_calculator.call(contract: contract),
          output_payments: output_payment_calculator.call(contract: contract, total_participants: aggregations[:eligible_and_payable]),
        }
      end

    private

      attr_accessor :contract, :service_fee_calculator, :breakdown_summart_calculator, :output_payment_calculator, :course_identifier

      def initialize(contract:,
                     course_identifier:,
                     breakdown_summary_calculator: BreakdownSummary,
                     output_payment_calculator: OutputPayment,
                     service_fee_calculator: ServiceFees)
        self.contract = contract
        self.course_identifier = course_identifier
        self.breakdown_summart_calculator = breakdown_summary_calculator
        self.output_payment_calculator = output_payment_calculator
        self.service_fee_calculator = service_fee_calculator
      end
    end
  end
end
