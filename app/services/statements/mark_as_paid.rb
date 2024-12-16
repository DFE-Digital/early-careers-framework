# frozen_string_literal: true

module Statements
  class MarkAsPaid
    def initialize(statement)
      self.statement = statement
    end

    def call
      Finance::Statement.transaction do
        participant_declarations.find_each do |participant_declaration|
          declaration_mark_as_paid_service.call(participant_declaration)
        end

        statement
          .participant_declarations
          .awaiting_clawback
          .each(&:make_clawed_back!)

        statement
          .statement_line_items
          .awaiting_clawback
          .each(&:clawed_back!)

        statement.paid!
      end
    end

  private

    attr_accessor :statement

    def participant_declarations
      statement.participant_declarations.payable
    end

    def declaration_mark_as_paid_service
      @declaration_mark_as_paid_service ||= ParticipantDeclarations::MarkAsPaid.new(statement)
    end
  end
end
