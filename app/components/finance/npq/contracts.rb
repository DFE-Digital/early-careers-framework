# frozen_string_literal: true

module Finance
  module NPQ
    class Contracts < BaseComponent
      include FinanceHelper
      attr_reader :lead_provider_name, :contracts

      def initialize(contracts:)
        @contracts = contracts
        @lead_provider_name = contracts.first.npq_lead_provider.name
      end
    end
  end
end
