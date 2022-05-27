# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class ContractInfo < BaseComponent
        def initialize(npq_contracts, npq_lead_provider)
          @npq_contracts = npq_contracts
          @npq_lead_provider = npq_lead_provider
        end

      private

        def number_to_pounds(number)
          number_to_currency number, precision: 2, unit: "£"
        end

        attr_reader :npq_contracts, :npq_lead_provider
      end
    end
  end
end
