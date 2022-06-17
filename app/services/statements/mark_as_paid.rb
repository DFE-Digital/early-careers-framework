# frozen_string_literal: true

module Statements
  class MarkAsPaid
    def initialize(statement)
      self.statement = statement
    end

    def call
      Finance::Statement.transaction do
        statement.paid!

        statement
          .participant_declarations
          .payable
          .each(&:make_paid!)

        statement
          .participant_declarations
          .awaiting_clawback
          .each(&:make_clawed_back!)

        statement
          .statement_line_items
          .payable
          .each(&:paid!)

        statement
          .statement_line_items
          .awaiting_clawback
          .each(&:clawed_back!)
      end
    end

  private

    attr_accessor :statement
  end
end
