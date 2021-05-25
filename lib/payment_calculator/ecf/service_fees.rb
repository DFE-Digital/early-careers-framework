# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

module PaymentCalculator
  module Ecf
    class ServiceFees
      include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations

      def call
        {
          service_fee_per_participant: service_fee_per_participant,
          service_fee_total: service_fee_total,
          service_fee_monthly: service_fee_monthly,
        }
      end
    end
  end
end

