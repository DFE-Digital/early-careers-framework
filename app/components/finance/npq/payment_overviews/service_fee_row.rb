# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class ServiceFeeRow < BaseComponent
        include FinanceHelper

        def initialize(service_fees, contract)
          @service_fees = service_fees
          @contract = contract
        end

        def total
          service_fees[:monthly]
        end

        def payment_per_trainee
          service_fees[:per_participant]
        end

        def trainees
          contract.recruitment_target
        end

      private

        attr_reader :service_fees, :contract
      end
    end
  end
end
