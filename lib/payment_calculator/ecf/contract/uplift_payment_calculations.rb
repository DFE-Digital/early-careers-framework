# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module Ecf
    module Contract
      module UpliftPaymentCalculations
        extend ActiveSupport::Concern

        included do
          include HasDIParameters
        end

        delegate :uplift_amount, to: :contract

        def uplift_payment_per_participant
          uplift_amount
        end

        def total_uplift_payment(eligible_participants)
          uplift_payment_per_participant * eligible_participants
        end
      end
    end
  end
end
