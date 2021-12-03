# frozen_string_literal: true

module Finance
  module NPQ
    class TotalPaymentRow < BaseComponent
      include FinanceHelper

      def initialize(payment_breakdown)
        self.payment_breakdown = payment_breakdown
      end

      def total
        monthly_service_fees + output_payment_subtotal
      end

    private

      attr_accessor :payment_breakdown

      def monthly_service_fees
        payment_breakdown.dig(:service_fees, :monthly)
      end

      def output_payment_subtotal
        payment_breakdown.dig(:output_payments, :subtotal)
      end
    end
  end
end
