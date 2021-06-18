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

        def uplift_payment_per_participant_for_event(event_type:)
          event_type == :started ? uplift_payment_per_participant : 0
        end

        def uplift_payment_for_event(uplift_participants:, event_type:)
          uplift_participants * uplift_payment_per_participant_for_event(event_type: event_type)
        end
      end
    end
  end
end
