# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewSummary < BaseComponent
        include NPQPaymentsHelper

        def initialize(contracts, statement, npq_lead_provider)
          @contracts = contracts
          @statement = statement
          @npq_lead_provider = npq_lead_provider
        end

      private

        attr_accessor :statement, :contracts, :npq_lead_provider
      end
    end
  end
end
