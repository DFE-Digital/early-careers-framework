# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class PaymentCalculation
      class << self
        def call(contract:,
                 breakdown_summary_compiler: BreakdownSummary,
                 service_fee_calculator: ServiceFees,
                 output_payment_aggregator: OutputPaymentAggregator,
                 aggregations: empty_aggregations,
                 event_type: :started)
          new(
            contract: contract,
            headings_calculator: breakdown_summary_compiler,
            service_fee_calculator: service_fee_calculator,
            output_payment_aggregator: output_payment_aggregator,
          ).call(aggregations: aggregations,
                 event_type: event_type)
        end

      private

        def empty_aggregations
          { all: 0 }
        end
      end

      def call(aggregations:, event_type: :started)
        {
          breakdown_summary: headings_calculator.call(contract: contract, event_type: event_type, aggregations: aggregations),
          service_fees: service_fee_calculator.call({ contract: contract }),
          output_payments: output_payment_aggregator.call({ contract: contract }, event_type: event_type, total_participants: aggregations[:all]),
        }
      end

    private

      attr_accessor :contract, :service_fee_calculator, :headings_calculator, :output_payment_aggregator

      def initialize(contract:,
                     headings_calculator: BreakdownSummary,
                     output_payment_aggregator: OutputPaymentAggregator,
                     service_fee_calculator: ServiceFees)
        @contract = contract
        @headings_calculator = headings_calculator
        @output_payment_aggregator = output_payment_aggregator
        @service_fee_calculator = service_fee_calculator
      end
    end
  end
end
