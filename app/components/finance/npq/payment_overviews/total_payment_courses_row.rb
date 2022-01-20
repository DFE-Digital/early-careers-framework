# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class TotalPaymentCoursesRow < BaseComponent
        include FinanceHelper

        def initialize(breakdowns, statement:, npq_lead_provider:)
          self.breakdowns = breakdowns
          self.statement  = statement
          self.npq_lead_provider = npq_lead_provider
        end

      private

        attr_accessor :breakdowns, :statement, :npq_lead_provider

        def npq_aggregated_total_payment_with_vat
          aggregated_payment(@breakdowns) + aggregated_vat(@breakdowns, @npq_lead_provider)
        end
      end
    end
  end
end
