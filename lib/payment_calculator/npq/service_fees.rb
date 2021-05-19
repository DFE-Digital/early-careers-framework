# frozen_string_literal: true

require "initialize_with_config"

module PaymentCalculator
  module Npq
    class ServiceFees
      include InitializeWithConfig
      delegate :recruitment_target, :per_participant_price, :number_of_service_fee_payments, to: :config

      def call
        {
          payment_schedule: service_fee_payment_schedule,
          total: total_service_fee,
        }
      end

    private

      def total_service_fee
        per_participant_price * 0.4 * recruitment_target
      end

      def monthly_service_fee
        (total_service_fee / number_of_service_fee_payments.to_d).round(2)
      end

      def service_fee_payment_schedule
        ([monthly_service_fee] * number_of_service_fee_payments).tap do |schedule|
          schedule[0] += total_service_fee - schedule.sum
        end
      end
    end
  end
end
