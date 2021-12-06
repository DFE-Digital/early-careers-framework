# frozen_string_literal: true

module Finance
  module NPQ
    class OutputFeeRow < BaseComponent
      include FinanceHelper

      def initialize(breakdown)
        self.breakdown = breakdown
      end

      def subtotal
        breakdown.dig(:output_payments, :subtotal)
      end

      def per_participant
        breakdown.dig(:output_payments, :per_participant)
      end

      def total_participants
        breakdown.dig(:breakdown_summary, :total_participants_paid)
      end

    private

      attr_accessor :breakdown
    end
  end
end
