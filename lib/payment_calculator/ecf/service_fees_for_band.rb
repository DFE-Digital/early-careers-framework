# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

module PaymentCalculator
  module Ecf
    class ServiceFeesForBand
      include Ecf::Contract::ServiceFeeCalculations

      def call(band:)
        {
          service_fee_monthly: service_fee_monthly(band).round(0),
          service_fee_per_participant: service_fee_per_participant(band).round(0),
          service_fee_total: service_fee_total(band).round(0),
        }
      end
    end
  end
end
