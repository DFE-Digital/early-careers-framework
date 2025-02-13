# frozen_string_literal: true

module Finance
  module Statements
    module PaymentBreakdown
      class ECF < BaseComponent
        include FinanceHelper

        attr_reader :statement, :calculator

        def initialize(statement:, calculator:)
          @statement = statement
          @calculator = calculator
        end

        def ecf_lead_provider
          statement.cpd_lead_provider.lead_provider
        end
      end
    end
  end
end
