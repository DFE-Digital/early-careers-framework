# frozen_string_literal: true

require "has_di_parameters"

module PaymentCalculator
  module ECF
    module Contract
      module OutputPaymentCalculations
        extend ActiveSupport::Concern

        included do
          include HasDIParameters
        end

        def output_payment_for_event(event_type:, total_participants:, band:)
          band.number_of_participants_in_this_band(total_participants) * output_payment_per_participant_for_event(event_type: event_type, band: band)
        end

        def output_payment_per_participant_for_event(event_type:, band:)
          event_type = event_type.parameterize.underscore.intern if event_type.is_a?(String)
          send(event_type) * band.output_payment_per_participant
        end

      private
        def start_and_completion_event_percentage
          0.2
        end

        alias_method :started, :start_and_completion_event_percentage
        alias_method :completion, :start_and_completion_event_percentage

        def interim_retained_period_event_percentage
          0.15
        end

        alias_method :retention_1, :interim_retained_period_event_percentage
        alias_method :retention_2, :interim_retained_period_event_percentage
        alias_method :retention_3, :interim_retained_period_event_percentage
        alias_method :retention_4, :interim_retained_period_event_percentage
      end
    end
  end
end
