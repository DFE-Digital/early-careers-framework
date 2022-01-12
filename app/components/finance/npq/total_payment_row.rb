# frozen_string_literal: true

module Finance
  module NPQ
    class TotalPaymentRow < BaseComponent
      include FinanceHelper

      def initialize(breakdown, lead_provider)
        self.breakdown = breakdown
        self.lead_provider = lead_provider
      end

    private

      attr_accessor :breakdown, :lead_provider
    end
  end
end
