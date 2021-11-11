# frozen_string_literal: true

module Finance
  module NPQ
    class ServiceFeeRow < BaseComponent
      include FinanceHelper
      attr_reader :service_fee

      def service_per_fee_participant
        service_fee[:per_participant]
      end

      def service_fees_total
        service_fee[:monthly]
      end

    private

      attr_writer :service_fee

      def initialize(service_fee)
        self.service_fee = service_fee
      end
    end
  end
end
