# frozen_string_literal: true

module Services
  module Npq
    class OutputPayment
      include InitializeWithConfig
      delegate :retention_points, :per_participant_price, to: :config

      def call
        retention_points.transform_values do |values|
          {
            per_participant: per_participant_output_payment,
            total_output_payment: total_output_payment(values[:retained_participants]),
          }
        end
      end

    private

      def output_payment_split
        1.0 / retention_points.length
      end

      def per_participant_output_payment
        (per_participant_price * 0.6 * output_payment_split).round(2)
      end

      def total_output_payment(retained_participants)
        (per_participant_output_payment * retained_participants).round(2)
      end
    end
  end
end
