# frozen_string_literal: true

module Finance
  module ECF
    class OutputPayments < BaseComponent
      include FinanceHelper

      def participants
        output_payments.map { |params| params[:participants] }.inject(&:+)
      end

      def subtotal
        output_payments.map { |params| params[:subtotal] }.inject(&:+)
      end

    private

      attr_reader :output_payments

      def initialize(output_payments:)
        @output_payments = output_payments
      end
    end
  end
end
