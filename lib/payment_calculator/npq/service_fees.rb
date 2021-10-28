# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class ServiceFees
      class << self
        def call(contract:)
          new(contract: contract).call
        end
      end

      def call
        { monthly: calculated_service_fee }
      end

    private

      attr_reader :contract

      delegate :recruitment_target, :per_participant, :service_fee_percentage, :service_fee_installments, to: :contract

      def calculated_service_fee
        service_fee_percentage.zero? ? 0 : recruitment_target * per_participant * service_fee_percentage / (100 * service_fee_installments)
      end

      def initialize(contract:)
        @contract = contract
      end
    end
  end
end
