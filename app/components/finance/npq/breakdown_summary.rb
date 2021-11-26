# frozen_string_literal: true

module Finance
  module NPQ
    class BreakdownSummary < BaseComponent
      include FinanceHelper

      def initialize(breakdown_summary)
        self.breakdown = breakdown_summary
      end

      def recruitment_target
        breakdown[:recruitment_target]
      end

      def participants
        breakdown[:participants]
      end

      def total_paid
        breakdown[:total_participants_paid]
      end

      def total_not_paid
        breakdown[:total_participants_not_paid]
      end

    private

      attr_accessor :breakdown
    end
  end
end
