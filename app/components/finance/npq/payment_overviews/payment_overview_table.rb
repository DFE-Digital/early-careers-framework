# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTable < BaseComponent
        include FinanceHelper

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

        attr_accessor :contract, :statement

        def service_fees
          @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
        end

        def output_fees
          @output_fees ||= PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: statement.participant_declarations
              .for_course_identifier(contract.course_identifier)
              .unique_paid_payable_or_eligible.count,
          )
        end
      end
    end
  end
end
