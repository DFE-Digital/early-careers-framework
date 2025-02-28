# frozen_string_literal: true

module Finance
  module Statements
    module DeclarationsBreakdown
      class Section < BaseComponent
        include FinanceHelper

        attr_reader :statement, :ect_calculator, :mentor_calculator

        def initialize(statement:, ect_calculator:, mentor_calculator:)
          @statement = statement
          @ect_calculator = ect_calculator
          @mentor_calculator = mentor_calculator
        end
      end
    end
  end
end
