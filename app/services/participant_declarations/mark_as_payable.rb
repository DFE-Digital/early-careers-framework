# frozen_string_literal: true

module ParticipantDeclarations
  class MarkAsPayable
    def initialize(statement)
      self.statement = statement
    end

    def call(participant_declaration)
      ParticipantDeclaration.transaction do
        participant_declaration.make_payable!

        line_item = statement
                      .statement_line_items
                      .find_by(participant_declaration:)

        line_item.payable! if line_item
      end
    end

  private

    attr_accessor :statement
  end
end
