# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class ServiceFeeRow < BaseComponent
        include NPQPaymentsHelper

        def initialize(service_fees, contract)
          @service_fees = service_fees
          @contract = contract
        end

        delegate :recruitment_target, to: :contract

      private

        attr_reader :service_fees, :contract
      end
    end
  end
end
