# frozen_string_literal: true

require "payment_calculator/ecf/service_fees_for_band"

module PaymentCalculator
  module Ecf
    class ServiceFees
      include HasDIParameters

      delegate :bands, to: :contract

      def call
        bands.each_with_index.map do |band, i|
          { band: band_to_identifier(i) }.merge(Ecf::ServiceFeesForBand.call(params, band: band))
        end
      end

      private
      def band_to_identifier(i)
        ("A".ord+i).chr
      end
    end
  end
end
