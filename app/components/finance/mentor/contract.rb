# frozen_string_literal: true

module Finance
  module Mentor
    class Contract < BaseComponent
      include FinanceHelper

      attr_accessor :contract

      delegate :recruitment_target, :payment_per_participant, to: :contract

      def initialize(contract:)
        @contract = contract
      end

      def name
        contract.lead_provider.name
      end
    end
  end
end
