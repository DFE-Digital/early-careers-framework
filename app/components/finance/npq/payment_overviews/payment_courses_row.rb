# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentCoursesRow < BaseComponent
        include FinanceHelper
        attr_reader :course_identifier, :npq_lead_provider

        with_collection_parameter :breakdown

        def initialize(statement:, breakdown:, npq_lead_provider:)
          self.statement                = statement
          self.course_identifier        = breakdown.dig(:breakdown_summary, :course_identifier)
          self.monthly_service_fees     = breakdown.dig(:service_fees, :monthly)
          self.output_payments_subtotal = breakdown.dig(:output_payments, :subtotal)
          self.npq_lead_provider        = npq_lead_provider
        end

        def npq_course_payment_total
          monthly_service_fees + output_payments_subtotal
        end

      private

        attr_accessor :output_payments_subtotal, :monthly_service_fees, :statement
        attr_writer :course_identifier, :npq_lead_provider
      end
    end
  end
end
