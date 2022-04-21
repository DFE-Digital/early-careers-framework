# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTable < BaseComponent
        include NPQPaymentsHelper

        def initialize(contract, statement)
          @contract = contract
          @statement = statement
        end

      private

        attr_accessor :statement, :contract, :npq_lead_provider

        def service_fees
          @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
        end

        def output_payment
          @output_payment ||= PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: total_declarations(contract),
          )
        end
      end
    end
  end
end
