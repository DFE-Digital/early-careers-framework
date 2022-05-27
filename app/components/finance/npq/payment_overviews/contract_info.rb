# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class ContractInfo < BaseComponent
        include FinanceHelper

        def initialize(npq_contracts, npq_lead_provider)
          @npq_contracts = npq_contracts
          @npq_lead_provider = npq_lead_provider
        end

      private

        attr_reader :npq_contracts, :npq_lead_provider
      end
    end
  end
end
