# frozen_string_literal: true

module Finance
  module ECF
    class OutputPayments < BaseComponent
      include FinanceHelper

      def participants
        output_payments.map { |params| params[:participants] }.inject(&:+)
      end

      def ineligible_participants
        breakdown_summary[:ineligible_participants]
      end

      def subtotal
        output_payments.map { |params| params[:subtotal] }.inject(&:+)
      end

    private

      attr_reader :output_payments, :breakdown_summary

      def initialize(output_payments:, breakdown_summary:)
        @output_payments = output_payments
        @breakdown_summary = breakdown_summary
      end
    end
  end
end
