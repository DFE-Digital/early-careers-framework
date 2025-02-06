# frozen_string_literal: true

module Finance
  module ECF
    module ECT
      class OutputCalculator < Finance::ECF::OutputCalculator
      private

        def previous_fill_level_for_declaration_type(declaration_type)
          billable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .billable
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.ects)
            .count

          refundable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .refundable
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.ects)
            .count

          billable - refundable
        end

        def previous_fill_level_for_uplift
          billable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .billable
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: "started" })
            .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
            .merge!(ParticipantDeclaration.ects)
            .count

          refundable = Finance::StatementLineItem
            .where(statement: statement.previous_statements)
            .refundable
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: "started" })
            .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
            .merge!(ParticipantDeclaration.ects)
            .count

          billable - refundable
        end

        def current_billable_count_for_declaration_type(declaration_type)
          statement
            .billable_statement_line_items
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.ects)
            .count
        end

        def current_refundable_count_declaration_type(declaration_type)
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.ects)
            .count
        end

        def current_billable_count_for_uplift
          statement
            .billable_statement_line_items
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: "started" })
            .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
            .merge!(ParticipantDeclaration.ects)
            .count
        end

        def current_refundable_count_for_uplift
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: "started" })
            .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
            .merge!(ParticipantDeclaration.ects)
            .count
        end
      end
    end
  end
end
