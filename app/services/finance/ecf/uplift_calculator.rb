# frozen_string_literal: true

module Finance
  module ECF
    class UpliftCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def previous_count
        previous_billable_count - previous_refundable_count
      end

      def count
        current_billable_count - current_refundable_count
      end

      def additions
        current_billable_count
      end

      def subtractions
        current_refundable_count
      end

    private

      def previous_billable_count
        @previous_billable_count ||=
          Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .billable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count
      end

      def previous_refundable_count
        @previous_refundable_count ||=
          Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .refundable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count
      end

      def current_billable_count
        @current_billable_count ||=
          statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count
      end

      def current_refundable_count
        @current_refundable_count ||=
          statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count
      end
    end
  end
end
