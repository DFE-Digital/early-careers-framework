# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module Ecf
    module Contract
      module ServiceFeeCalculations
        class << self
          def included(base)
            base.class_eval do
              include HasDIParameters
            end
          end
        end

        delegate :recruitment_target,
                 :set_up_fee,
                 :band_a, to: :contract

        def service_fee_total
          recruitment_target * service_fee_per_participant
        end

        def service_fee_monthly
          (service_fee_total / number_of_service_fee_payments)
        end

        def service_fee_per_participant
          band_a.per_participant * service_fee_payment_contribution_percentage - set_up_cost_per_participant
        end

      private

        def service_fee_payment_contribution_percentage
          0.4
        end

        def set_up_cost_per_participant
          set_up_fee / recruitment_target
        end

        def number_of_service_fee_payments
          29
        end
      end
    end
  end
end
