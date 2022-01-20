# frozen_string_literal: true

module Finance
  module ECF
    class OutputPayments < BaseComponent
      include FinanceHelper

      def initialize(output_payments:, breakdown_summary:)
        @output_payments = output_payments
        @breakdown_summary = breakdown_summary
      end

      def participants
        output_payments.map { |params| params[:participants] }.inject(&:+)
      end

      def not_yet_included_participants
        breakdown_summary[:not_yet_included_participants]
      end

      def subtotal
        output_payments.map { |params| params[:subtotal] }.inject(&:+)
      end

    private

      attr_reader :output_payments, :breakdown_summary
    end
  end
end
