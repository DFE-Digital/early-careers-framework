# frozen_string_literal: true

module PaymentCalculator
  module NPQ
    class ServiceFees
      class << self
        def call(contract:)
          new(contract:).call
        end
      end

      def call
        {
          per_participant: per_participant_portion,
          monthly: calculated_service_fee,
        }
      end

    private

      attr_accessor :contract

      delegate :recruitment_target, :per_participant, :service_fee_percentage, :service_fee_installments, to: :contract

      def per_participant_portion
        service_fee_percentage.zero? ? 0 : per_participant * service_fee_percentage / (100 * service_fee_installments)
      end

      def calculated_service_fee
        recruitment_target * per_participant_portion
      end

      def initialize(contract:)
        self.contract = contract
      end
    end
  end
end
