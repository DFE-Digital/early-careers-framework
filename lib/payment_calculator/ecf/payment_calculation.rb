# frozen_string_literal: true

require "payment_calculator/ecf/breakdown_summary"
require "payment_calculator/ecf/service_fees"
require "payment_calculator/ecf/output_payment_calculator"
require "payment_calculator/ecf/uplift_calculation"

module PaymentCalculator
  module ECF
    class PaymentCalculation
      class << self
        def call(contract:,
                 breakdown_summary_compiler: BreakdownSummary,
                 service_fee_calculator: ServiceFees,
                 output_payment_calculator: OutputPaymentCalculator,
                 uplift_payment_calculator: UpliftCalculation,
                 aggregations: empty_aggregations,
                 event_type: :started)
          new(
            contract:,
            headings_calculator: breakdown_summary_compiler,
            service_fee_calculator:,
            output_payment_calculator:,
            uplift_payment_calculator:,
          ).call(aggregations:,
                 event_type:)
        end

      private

        def empty_aggregations
          { all: 0, ects: 0, mentors: 0, uplift: 0, previous_declarations: 0 }
        end
      end

      def call(aggregations:, event_type: :started)
        {
          breakdown_summary: headings_calculator.call(contract:, event_type:, aggregations:),
          service_fees: service_fee_calculator.call({ contract: }),
          output_payments: output_payment_calculator.call(
            { contract: },
            event_type:,
            total_participants: aggregations[:all],
            total_previous_participants: aggregations[:previous_participants],
          ),
          other_fees: uplift_payment_calculator.call({ contract: }, event_type:, uplift_participants: aggregations[:uplift]),
        }
      end

    private

      attr_accessor :contract, :service_fee_calculator, :headings_calculator, :output_payment_calculator, :uplift_payment_calculator

      def initialize(contract:,
                     headings_calculator:,
                     output_payment_calculator:,
                     service_fee_calculator:,
                     uplift_payment_calculator:)
        @contract = contract
        @headings_calculator = headings_calculator
        @output_payment_calculator = output_payment_calculator
        @service_fee_calculator = service_fee_calculator
        @uplift_payment_calculator = uplift_payment_calculator
      end
    end
  end
end
