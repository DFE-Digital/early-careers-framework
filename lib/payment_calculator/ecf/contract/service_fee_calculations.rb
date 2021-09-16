# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module ECF
    module Contract
      module ServiceFeeCalculations
        extend ActiveSupport::Concern

        included do
          include HasDIParameters
        end

        delegate :recruitment_target, to: :contract

        def service_fee_total(band)
          band.number_of_participants_in_this_band(recruitment_target) * band.service_fee_per_participant
        end

        def service_fee_monthly(band)
          service_fee_total(band) / number_of_service_fee_payments
        end

      private
        def number_of_service_fee_payments
          29
        end
      end
    end
  end
end
