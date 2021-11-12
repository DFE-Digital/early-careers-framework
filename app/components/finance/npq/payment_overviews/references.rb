# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class References < BaseComponent
        include FinanceHelper
        attr_reader :cohort, :payment_reference

        def submission_deadline
          Date.parse(payment_period.last).to_s(:govuk)
        end

      private

        attr_writer :cohort, :payment_reference
      end
    end
  end
end
