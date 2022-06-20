# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class Course < BaseComponent
        include FinanceHelper

        attr_reader :statement, :contract

        def initialize(statement:, contract:)
          @statement = statement
          @contract = contract
        end

        def calculator
          @calculator ||= CourseStatementCalculator.new(
            statement:,
            contract:,
          )
        end
      end
    end
  end
end
