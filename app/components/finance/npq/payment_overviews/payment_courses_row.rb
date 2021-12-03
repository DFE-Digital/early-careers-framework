# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentCoursesRow < BaseComponent
        include FinanceHelper
        attr_reader :course_identifier, :npq_lead_provider

        with_collection_parameter :breakdown

        def total
          output_payments_subtotal + service_fees_monthly
        end

      private

        attr_accessor :output_payments_subtotal, :service_fees_monthly
        attr_writer :course_identifier, :npq_lead_provider

        def initialize(breakdown:, npq_lead_provider:)
          self.course_identifier        = breakdown.dig(:breakdown_summary, :course_identifier)
          self.service_fees_monthly     = breakdown.dig(:service_fees, :monthly)
          self.output_payments_subtotal = breakdown.dig(:output_payments, :subtotal)
          self.npq_lead_provider        = npq_lead_provider
        end
      end
    end
  end
end
