# frozen_string_literal: true

module Finance
  module ECF
    module ECT
      class BandingCalculator < Finance::ECF::BandingCalculator
      private

        def previous_billable_count
          Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .billable
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.ect)
            .count
        end

        def previous_refundable_count
          Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .refundable
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.ect)
            .count
        end

        def current_billable_count
          statement
            .billable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.ect)
            .count
        end

        def current_refundable_count
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.ect)
            .count
        end
      end
    end
  end
end
