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

        def service_fee_monthly(band)
          band.service_fee_total / number_of_service_fee_payments
        end

      private

        def number_of_service_fee_payments
          29
        end
      end
    end
  end
end
