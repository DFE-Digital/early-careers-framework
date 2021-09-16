# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

module PaymentCalculator
  module ECF
    class ServiceFeesForBand
      include ECF::Contract::ServiceFeeCalculations
      delegate :recruitment_target, to: :contract

      def call(band:)
        {
          participants: band.number_of_participants_in_this_band(recruitment_target),
          per_participant: band.service_fee_per_participant,
          monthly: service_fee_monthly(band),
        }
      end
    end
  end
end
