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
        { monthly: recruitment_target * per_participant * service_fee_percentage / (100 * service_fee_installments) } unless service_fee_percentage.to_i.zero?
      end

    private

      attr_reader :contract

      delegate :recruitment_target, :per_participant, :service_fee_percentage, :service_fee_installments, to: :contract

      def initialize(contract:)
        @contract = contract
      end
    end
  end
end
