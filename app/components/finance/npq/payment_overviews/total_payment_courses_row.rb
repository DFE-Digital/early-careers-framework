# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class TotalPaymentCoursesRow < BaseComponent
        include FinanceHelper

        def initialize(breakdowns, npq_lead_provider)
          self.breakdowns = breakdowns
          self.npq_lead_provider = npq_lead_provider
        end

      private

        attr_accessor :breakdowns, :npq_lead_provider
      end
    end
  end
end
