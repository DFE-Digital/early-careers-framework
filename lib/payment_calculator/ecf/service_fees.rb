# frozen_string_literal: true

require "payment_calculator/ecf/service_fees_for_band"

module PaymentCalculator
  module ECF
    class ServiceFees
      include HasDIParameters

      delegate :bands, to: :contract

      def call
        bands.each_with_index.map do |band, i|
          { band: band_to_identifier(i) }.merge(ECF::ServiceFeesForBand.call(params, band: band))
        end
      end

    private

      def band_to_identifier(index)
        ("A".ord + index).chr
      end
    end
  end
end
