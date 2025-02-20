# frozen_string_literal: true

module Finance
  module Statements
    module OutputPayments
      class ECF < BaseComponent
        include FinanceHelper

        attr_reader :calculator

        def initialize(calculator:)
          @calculator = calculator
        end
      end
    end
  end
end
