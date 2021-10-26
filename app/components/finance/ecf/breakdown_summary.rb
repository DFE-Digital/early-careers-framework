# frozen_string_literal: true

module Finance
  module ECF
    class BreakdownSummary < BaseComponent
      include FinanceHelper
    # TODO: include revised_target in here somewhere :P

    private

      def initialize(breakdown_summary:, lead_provider:, payment_period:)
        @lead_provider = lead_provider
        @breakdown = breakdown_summary
        @service_fees_participants = @breakdown[:service_fees].map { |params| params[:participants] }.inject(&:+)
        @service_fees_total = @breakdown[:service_fees].map { |params| params[:monthly] }.inject(&:+)
        @output_payment_participants = @breakdown[:output_payments].map { |params| params[:participants] }.inject(&:+)
        @output_payment_total = @breakdown[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
        @payment_period = pretty_payment_period
        @deadline = Date.parse(payment_period.last).to_s(:govuk)
        @payment_period = payment_period
      end
    end
  end
end
