# frozen_string_literal: true

module Finance
  module ECF
    module ECT
      class OutputCalculator < Finance::ECF::OutputCalculator
      private

        def previous_fill_level_for_uplift
          billable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .billable
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration("started"))
            .merge!(ParticipantDeclaration.uplift)
            .merge!(ParticipantDeclaration.ect)
            .count

          refundable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .refundable
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration("started"))
            .merge!(ParticipantDeclaration.uplift)
            .merge!(ParticipantDeclaration.ect)
            .count

          billable - refundable
        end

        def current_billable_count_for_uplift
          statement
            .billable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration("started"))
            .merge!(ParticipantDeclaration.uplift)
            .merge!(ParticipantDeclaration.ect)
            .count
        end

        def current_refundable_count_for_uplift
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration("started"))
            .merge!(ParticipantDeclaration.uplift)
            .merge!(ParticipantDeclaration.ect)
            .count
        end
      end
    end
  end
end
