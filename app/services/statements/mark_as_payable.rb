# frozen_string_literal: true

module Statements
  class MarkAsPayable
    def initialize(statement)
      self.statement = statement
    end

    def call
      Finance::Statement.transaction do
        participant_declarations.find_each do |declaration|
          declaration_mark_as_payable_service.call(declaration)
        end
        statement.payable!
      end
    end

  private

    attr_accessor :statement

    def participant_declarations
      statement.participant_declarations.eligible
    end

    def declaration_mark_as_payable_service
      @declaration_mark_as_payable_service ||= ParticipantDeclarations::MarkAsPayable.new(statement)
    end
  end
end
