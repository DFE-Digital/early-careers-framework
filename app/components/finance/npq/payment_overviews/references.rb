# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class References < BaseComponent
        def initialize(invoice)
          self.invoice = invoice
        end

        def submission_deadline
          invoice.deadline_date.to_s(:govuk)
        end

      private

        attr_accessor :invoice
      end
    end
  end
end
