# frozen_string_literal: true

module Finance
  module ECF
    class OtherFees < BaseComponent
      include FinanceHelper
      def participants
        other_fees.map(&:participants).inject(&:+)
      end

      def subtotal
        other_fees.map(&:subtotal).inject(&:+)
      end

      private
      attr_accessor :other_fees

      def initialize(params:)
        self.other_fees = params.map { |other_fee| OtherFee.new(other_fee) }
      end
    end
  end
end
