# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class Course < BaseComponent
        attr_reader :statement, :contract

        def initialize(statement:, contract:)
          @statement = statement
          @contract = contract
        end

        def calculator
          @calculator ||= CourseStatementCalculator.new(
            statement: statement,
            contract: contract,
          )
        end

        def number_to_pounds(number)
          number_to_currency number, precision: 2, unit: "£"
        end
      end
    end
  end
end
