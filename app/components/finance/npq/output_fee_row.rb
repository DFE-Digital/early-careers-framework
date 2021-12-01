# frozen_string_literal: true

module Finance
  module NPQ
    class OutputFeeRow < BaseComponent
      include FinanceHelper

      def initialize(output_fee)
        self.output_fee = output_fee
      end

      def subtotal
        output_fee[:subtotal]
      end

      def per_participant
        output_fee[:per_participant]
      end

    private

      attr_accessor :output_fee
    end
  end
end
