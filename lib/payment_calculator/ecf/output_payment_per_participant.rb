# frozen_string_literal: true

require "initialize_with_config"

module PaymentCalculator
  module Ecf
    class OutputPaymentPerParticipant
      include InitializeWithConfig
      delegate :band_a, to: :config

      def call
        output_payment_per_participant
      end

    private

      def output_payment_per_participant
        band_a * 0.6
      end
    end
  end
end
