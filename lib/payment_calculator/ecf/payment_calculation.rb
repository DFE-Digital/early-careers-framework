# frozen_string_literal: true

require "has_di_parameters"
require "payment_calculator/ecf/service_fees"
require "payment_calculator/ecf/output_payment_aggregator"

module PaymentCalculator
  module Ecf
    class PaymentCalculation
      include HasDIParameters

      # @param [Symbol] event_type
      # @param [Integer] total_participants
      # This is end number of participants who will be used to make the payment calculation.
      # All invalid users will have already been filtered out before this number is generated and passed here.
      def call(total_participants: 0, event_type: :started)
        params[:contract] ||= lead_provider.call_off_contract
        {
          service_fees: service_fee_calculator.call(params),
          output_payment: output_payment_calculator.call(params, event_type: event_type, total_participants: total_participants),
        }
      end

    private

      def default_params
        {
          service_fee_calculator: ::PaymentCalculator::Ecf::ServiceFees,
          output_payment_calculator: ::PaymentCalculator::Ecf::OutputPaymentAggregator,
        }
      end
    end
  end
end
