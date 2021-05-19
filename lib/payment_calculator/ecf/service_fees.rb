# frozen_string_literal: true

module PaymentCalculator
  module Ecf
    class ServiceFees
      include InitializeWithConfig
      delegate :band_a, :recruitment_target, :setup_fee, to: :config

      def call
        {
          service_fee_per_participant: service_fee_per_participant,
          service_fee_total: service_fee_total,
          service_fee_monthly: service_fee_monthly,
        }
      end

    private

      def number_of_service_fee_payments
        29
      end

      def setup_cost_per_participant
        setup_fee.to_i / recruitment_target
      end

      def service_fee_per_participant
        (band_a * 0.4 - setup_cost_per_participant).round(0)
      end

      def service_fee_total
        recruitment_target * service_fee_per_participant
      end

      def service_fee_monthly
        (service_fee_total / number_of_service_fee_payments).round(0)
      end
    end
  end
end
