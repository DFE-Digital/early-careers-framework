# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class ServiceFeeRow < BaseComponent
        include FinanceHelper

        def initialize(service_fees)
          @service_fees = service_fees
        end

      private

        attr_accessor :service_fees
      end
    end
  end
end
