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

      private

        attr_accessor :statement, :contract, :lead_provider

        def service_fees
          @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
        end

        def output_payments
          @output_payments ||= PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: statement_declarations,
          )
        end

        def statement_declarations
          if statement.current?
            ParticipantDeclaration::NPQ
              .eligible_for_lead_provider(lead_provider)
              .where(statement_id: nil)
              .count
          else
            statement
              .participant_declarations
              .paid_payable_or_eligible
              .unique_id
              .count
          end
        end
      end
    end
  end
end
