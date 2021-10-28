# frozen_string_literal: true

module Finance
  module ECF
    class ServiceFees < BaseComponent
      include FinanceHelper

      def participants
        service_fees.map { |params| params[:participants] }.inject(&:+)
      end

      def monthly
        service_fees.map { |params| params[:monthly] }.inject(&:+)
      end

    private

      attr_reader :service_fees

      def initialize(service_fees:)
        @service_fees = service_fees
      end
    end
  end
end
