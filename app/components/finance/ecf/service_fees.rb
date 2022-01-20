# frozen_string_literal: true

module Finance
  module ECF
    class ServiceFees < BaseComponent
      include FinanceHelper

      def initialize(service_fees:, breakdown_summary:)
        @service_fees = service_fees
        @breakdown_summary = breakdown_summary
      end

      def participants
        service_fees.map { |params| params[:participants] }.inject(&:+)
      end

      def monthly
        service_fees.map { |params| params[:monthly] }.inject(&:+)
      end

    private

      attr_reader :service_fees, :breakdown_summary
    end
  end
end
