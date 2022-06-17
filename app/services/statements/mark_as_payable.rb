# frozen_string_literal: true

module Statements
  class MarkAsPayable
    attr_reader :statement

    def initialize(statement:)
      @statement = statement
    end

    def call
      Finance::Statement.transaction do
        statement
          .participant_declarations
          .eligible
          .each(&:make_payable!)

        statement
          .statement_line_items
          .eligible
          .each(&:payable!)
      end
    end
  end
end
