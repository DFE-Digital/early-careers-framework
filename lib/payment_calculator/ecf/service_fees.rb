# frozen_string_literal: true

require "payment_calculator/ecf/service_fees_for_band"

module PaymentCalculator
  module Ecf
    class ServiceFees
      include PaymentCalculator::Ecf::Contract::ServiceFeeCalculations
      delegate :bands, to: :contract

      def call
        bands.map do |band|
          Ecf::ServiceFeesForBand.call(params, band: band)
        end
      end
    end
  end
end
