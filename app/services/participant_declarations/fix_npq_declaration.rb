# frozen_string_literal: true

module ParticipantDeclarations
  class FixNPQDeclaration
    def initialize(ecf_statement, npq_statement)
      self.ecf_statement = ecf_statement
      self.npq_statement = npq_statement
    end

    def call(participant_declaration)
      ParticipantDeclaration.transaction do
        participant_declaration.statement_line_items.find_by(statement: ecf_statement).update!(statement: npq_statement)
        participant_declaration.update!(type: "ParticipantDeclaration::NPQ")
      end
    end

  private

    attr_accessor :ecf_statement, :npq_statement
  end
end
