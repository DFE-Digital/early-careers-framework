# frozen_string_literal: true

module ParticipantDeclarations
  class MarkAsPaid
    def initialize(statement)
      self.statement = statement
    end

    def call(participant_declaration)
      ParticipantDeclaration.transaction do
        participant_declaration.make_paid!

        line_item = statement
                      .statement_line_items
                      .find_by(participant_declaration:)

        line_item.paid! if line_item && line_item.payable?
      end
    end

  private

    attr_accessor :statement
  end
end
