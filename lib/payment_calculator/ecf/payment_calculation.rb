# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"
require "payment_calculator/ecf/output_payment_aggregator"
require "payment_calculator/ecf/uplift_payment_aggregator"

module PaymentCalculator
  module Ecf
    class PaymentCalculation
      class << self
        def call(lead_provider:, service_fee_calculator: ::PaymentCalculator::Ecf::ServiceFees, output_payment_aggregator: ::PaymentCalculator::Ecf::OutputPaymentAggregator, total_participants: 0, event_type: :started)
          new(lead_provider: lead_provider, service_fee_calculator: service_fee_calculator, output_payment_aggregator: output_payment_aggregator).call(total_participants: total_participants, event_type: event_type)
        end
      end

      # @param [Symbol] event_type
      # @param [Integer] total_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(total_participants: 0, event_type: :started, uplift_eligible_participants: 0)
        {
          service_fees: @service_fee_calculator.call(contract: contract),
          output_payments: @output_payment_aggregator.call({ contract: contract }, event_type: event_type, total_participants: total_participants),
          uplift_payment: @uplift_payment_aggregator.call({ contract: contract }, event_type: event_type, total_participants: total_participants, uplift_eligible_participants: uplift_eligible_participants),
        }
      end

    private

      def initialize(lead_provider:,
                     service_fee_calculator: ::PaymentCalculator::Ecf::ServiceFees,
                     output_payment_aggregator: ::PaymentCalculator::Ecf::OutputPaymentAggregator,
                     uplift_payment_aggregator: ::PaymentCalculator::Ecf::UpliftPaymentAggregator)
        @service_fee_calculator = service_fee_calculator
        @output_payment_aggregator = output_payment_aggregator
        @uplift_payment_aggregator = uplift_payment_aggregator
        @lead_provider = lead_provider
      end

      def contract
        @lead_provider.call_off_contract
      end
    end
  end
end
