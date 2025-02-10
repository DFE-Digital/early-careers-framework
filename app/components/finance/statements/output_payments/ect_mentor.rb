# frozen_string_literal: true

module Finance
  module Statements
    module OutputPayments
      class ECTMentor < BaseComponent
        include FinanceHelper

        attr_reader :ect_calculator, :mentor_calculator

        def initialize(ect_calculator:, mentor_calculator:)
          @ect_calculator = ect_calculator
          @mentor_calculator = mentor_calculator
        end
      end
    end
  end
end
