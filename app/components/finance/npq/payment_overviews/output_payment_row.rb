# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class OutputPaymentRow < BaseComponent
        include FinanceHelper

        attr_accessor :output_payment, :contract, :statement

        def initialize(output_payment, contract, statement)
          @output_payment = output_payment
          @contract = contract
          @statement = statement
        end

        def total
          output_payment[:subtotal]
        end

        def payment_per_trainee
          output_payment[:per_participant]
        end

        def current_trainees
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
