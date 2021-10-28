# frozen_string_literal: true

module Finance
  module NPQ
    class Contract < BaseComponent
      include FinanceHelper
      attr_accessor :contract

      delegate :recruitment_target, to: :contract

      def name
        contract.lead_provider.name
      end

    private

      def initialize(contract:)
        @contract = contract
      end
    end
  end
end
