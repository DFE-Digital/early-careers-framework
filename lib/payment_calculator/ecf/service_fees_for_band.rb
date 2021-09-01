# frozen_string_literal: true

require "payment_calculator/ecf/contract/service_fee_calculations"

module PaymentCalculator
  module ECF
    class ServiceFeesForBand
      include ECF::Contract::ServiceFeeCalculations

      def call(band:)
        {
          participants: band.number_of_participants_in_this_band(recruitment_target),
          per_participant: service_fee_per_participant(band),
          monthly: service_fee_monthly(band),
        }
      end
    end
  end
end
