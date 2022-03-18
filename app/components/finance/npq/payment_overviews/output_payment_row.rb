# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class OutputPaymentRow < BaseComponent
        include FinanceHelper

        attr_accessor :output_payment, :contract, :statement, :npq_lead_provider

        def initialize(output_payment, contract, statement, npq_lead_provider)
          @output_payment = output_payment
          @contract = contract
          @statement = statement
          @npq_lead_provider = npq_lead_provider
        end

        def total
          output_payment[:subtotal]
        end

        def payment_per_participant
          output_payment[:per_participant]
        end

        def total_declarations
          if statement.current?
            ParticipantDeclaration::NPQ
              .eligible_for_lead_provider(npq_lead_provider)
              .for_course_identifier(contract.course_identifier)
              .where(statement_id: nil)
              .count
          else
            statement
              .participant_declarations
              .for_course_identifier(contract.course_identifier)
              .paid_payable_or_eligible
              .unique_id
              .count
          end
        end
      end
    end
  end
end
