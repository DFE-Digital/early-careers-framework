# frozen_string_literal: true

require "initialize_with_config"
require "payment_calculator/ecf/service_fees_for_band"

module PaymentCalculator
  module Ecf
    class ServiceFees
      include InitializeWithConfig
      # required_config :contract # TODO: Uncomment this when the updated InitializeWithConfig is added from the other PR
      delegate :bands, to: :contract

      def call
        bands.map do |band|
          Ecf::ServiceFeesForBand.call(config, band: band)
        end
      end
    end
  end
end
