# frozen_string_literal: true

module Finance
  # Given a declaration
  # Work out which statement it should belong to
  # Attach the declaration to said statement
  class DeclarationStatementAttacher
    def initialize(participant_declaration)
      self.participant_declaration = participant_declaration
    end

    def call
      ApplicationRecord.transaction do
        statement.statement_line_items.create_or_find_by(
          participant_declaration:,
          state: participant_declaration.state,
        )
      end
    end

  private

    attr_accessor :participant_declaration

    def cohort
      participant_declaration.participant_profile.schedule_for(cpd_lead_provider:).cohort
    end

    def cpd_lead_provider
      participant_declaration.cpd_lead_provider
    end

    def statement
      case participant_declaration
      when ParticipantDeclaration::ECF
        participant_declaration.cpd_lead_provider.lead_provider.next_output_fee_statement(cohort)
      when ParticipantDeclaration::NPQ
        participant_declaration.cpd_lead_provider.npq_lead_provider.next_output_fee_statement(cohort)
      end
    end
  end
end
