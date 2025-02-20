# frozen_string_literal: true

module Finance
  module Statements
    module PaymentBreakdown
      class ECTMentor < BaseComponent
        include FinanceHelper

        attr_reader :statement, :ect_calculator, :mentor_calculator

        def initialize(statement:, ect_calculator:, mentor_calculator:)
          @statement = statement
          @ect_calculator = ect_calculator
          @mentor_calculator = mentor_calculator
        end

        def ecf_lead_provider
          statement.cpd_lead_provider.lead_provider
        end

        def total_amount
          ect_calculator.total(with_vat: true) + mentor_calculator.total(with_vat: true)
        end

        def total_vat
          ect_calculator.vat + mentor_calculator.vat
        end
      end
    end
  end
end
