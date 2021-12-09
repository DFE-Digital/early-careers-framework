# frozen_string_literal: true

module Finance
  module NPQ
    class ServiceFeeRow < BaseComponent
      include FinanceHelper
      attr_reader :service_fee

      def initialize(breakdown)
        self.breakdown = breakdown
      end

      def service_per_fee_participant
        breakdown.dig(:service_fees, :per_participant)
      end

      def service_fees_total
        breakdown.dig(:service_fees, :monthly)
      end

      def total_participants
        breakdown.dig(:breakdown_summary, :recruitment_target)
      end

    private

      attr_accessor :breakdown
    end
  end
end
