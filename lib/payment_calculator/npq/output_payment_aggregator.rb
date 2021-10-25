# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class OutputPaymentAggregator
      class << self
        def call(contract:, total_participants:)
          contract.paid_milestone_output_payment_basis * total_participants
        end
      end
    end
  end
end
