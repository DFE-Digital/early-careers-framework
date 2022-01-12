# frozen_string_literal: true

module Finance
  module NPQ
    class Contracts < BaseComponent
      include FinanceHelper
      attr_reader :lead_provider_name, :npq_contracts

      def initialize(npq_contracts:)
        @npq_contracts = npq_contracts
        @lead_provider_name = npq_contracts.first.npq_lead_provider.name
      end
    end
  end
end
