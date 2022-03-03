# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class OutputPaymentRow < BaseComponent
        include FinanceHelper

        attr_accessor :output_payment, :contract

        def initialize(output_payment, contract)
          @output_payment = output_payment
          @contract = contract
        end

        def total
          output_payment[:subtotal]
        end

        def payment_per_trainee
          output_payment[:per_participant]
        end

        def trainees
          contract.recruitment_target
        end
      end
    end
  end
end
