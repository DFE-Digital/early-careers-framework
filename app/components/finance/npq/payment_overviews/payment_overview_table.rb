# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTable < BaseComponent
        include FinanceHelper

        attr_reader :contract

        def initialize(contract, statement)
          @contract = contract
          @statement = statement
        end

        def service_fee
          { service_fee: service_fees }
        end

        def monthly_output_fees
          output_fees[:subtotal]
        end

      private

        attr_reader :statement

        def service_fees
          @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
        end

        def output_fees
          @output_fees ||= PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: statement.declarations.count,
          )
        end
      end
    end
  end
end
