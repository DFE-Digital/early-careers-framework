# frozen_string_literal: true

module Finance
  module Statements
    module PaymentBreakdown
      class Totals < BaseComponent
        include FinanceHelper

        attr_accessor :calculator, :mentor_calculator

        def initialize(calculator:, mentor_calculator:)
          @calculator = calculator
          @mentor_calculator = mentor_calculator
        end

        def total_amount
          number_to_pounds(calculator.total(with_vat: true) + mentor_calculator.total(with_vat: true))
        end

        def total_vat
          number_to_pounds(calculator.vat + mentor_calculator.vat)
        end
      end
    end
  end
end
