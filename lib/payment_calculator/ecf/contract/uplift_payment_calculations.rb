# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module ECF
    module Contract
      module UpliftPaymentCalculations
        extend ActiveSupport::Concern

        included do
          include HasDIParameters
        end

        delegate :uplift_amount, :uplift_cap, to: :contract

        def uplift_payment_per_participant
          uplift_amount
        end

        def uplift_payment_per_participant_for_event(event_type:)
          event_type == :started ? uplift_payment_per_participant : 0
        end

        def uplift_payment_for_event(uplift_participants:, event_type:)
          [uplift_participants * uplift_payment_per_participant_for_event(event_type:), uplift_cap].min
        end
      end
    end
  end
end
