# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class References < BaseComponent
        include FinanceHelper
        attr_reader :deadline, :breakdown

        def version
          breakdown[:version]
        end

      private

        def initialize(references)
          @breakdown = references
          @deadline  = Date.parse(payment_period.last).to_s(:govuk)
        end
      end
    end
  end
end
