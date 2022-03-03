# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTotal < BaseComponent
        include FinanceHelper

        def initialize(service_fees, output_payments, lead_provider)
          @service_fees = service_fees
          @output_payments = output_payments
          @lead_provider = lead_provider
        end

      private

        attr_accessor :service_fees, :output_payments, :lead_provider

        def course_total
          course_payment + total_vat(lead_provider)
        end

        def course_payment
          monthly_service_fees + output_payment_subtotal
        end

        def total_vat(lead_provider)
          course_payment * (lead_provider.vat_chargeable ? 0.2 : 0.0)
        end

        def monthly_service_fees
          service_fees[:monthly]
        end

        def output_payment_subtotal
          output_payments[:subtotal]
        end
      end
    end
  end
end
