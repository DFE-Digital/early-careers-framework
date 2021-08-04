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

      attr_reader :other_fees

      def initialize(other_fees:)
        @other_fees = other_fees.map { |other_fee| OtherFee.new(other_fee) }
      end
    end
  end
end
