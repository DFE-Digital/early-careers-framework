# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTable < BaseComponent
        include FinanceHelper

        def initialize(contract, statement, lead_provider)
          @contract = contract
          @statement = statement
          @lead_provider = lead_provider
        end

        # def service_fee
        #   { service_fee: service_fees }
        # end

        def monthly_output_payments
          output_payments[:subtotal]
        end

      private

        attr_accessor :statement, :contract, :lead_provider

        def service_fees
          @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
        end

        def output_payments
          @output_payments ||= PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: statement.participant_declarations.unique_paid_payable_or_eligible.count,
          )
        end
      end
    end
  end
end
