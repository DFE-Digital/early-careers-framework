# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class OutputPaymentRow < BaseComponent
        include NPQPaymentsHelper

        attr_accessor :output_payment, :contract, :statement, :npq_lead_provider

        def initialize(output_payment, contract, statement, npq_lead_provider)
          @output_payment = output_payment
          @contract = contract
          @statement = statement
          @npq_lead_provider = npq_lead_provider
        end
      end
    end
  end
end
