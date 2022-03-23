# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTotal < BaseComponent
        include NPQPaymentsHelper

        def initialize(service_fees, output_payment, npq_lead_provider)
          @service_fees = service_fees
          @output_payment = output_payment
          @npq_lead_provider = npq_lead_provider
        end

      private

        attr_accessor :service_fees, :output_payment, :npq_lead_provider
      end
    end
  end
end
