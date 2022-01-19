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
      end
    end
  end
end
