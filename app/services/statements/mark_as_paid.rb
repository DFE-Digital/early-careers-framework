module Statements
  class MarkAsPaid
    def initialize(statement)
      self.statement = statement
    end

    def call
      Finance::Statement.transaction do
        statement
          .participant_declarations
          .payable
          .each(&:make_paid!)
        statement.update!(type: "Finance::Statement::NPQ::Payable")
      end
    end

  private

    attr_accessor :statement
  end
end
