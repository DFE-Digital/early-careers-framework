# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module Ecf
    module Contract
      module ServiceFeeCalculations
        extend ActiveSupport::Concern

        included do
          include HasDIParameters
        end

        delegate :recruitment_target, :set_up_fee, :set_up_recruitment_basis, to: :contract

        def service_fee_total(band)
          band.number_of_participants_in_this_band(recruitment_target) * service_fee_per_participant(band)
        end

        def service_fee_monthly(band)
          (service_fee_total(band) / number_of_service_fee_payments)
        end

        def service_fee_per_participant(band)
          band.per_participant * service_fee_payment_contribution_percentage - deduction_for_band(band)
        end

      private

        def deduction_for_band(band)
          band.deduction_for_setup? ? set_up_cost_per_participant : 0
        end

        def service_fee_payment_contribution_percentage
          0.4
        end

        def set_up_cost_per_participant
          set_up_fee / set_up_recruitment_basis
        end

        def number_of_service_fee_payments
          29
        end
      end
    end
  end
end
