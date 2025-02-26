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

      def previous_statement_line_items
        Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
      end

      def previous_billable_count
        @previous_billable_count ||=
          previous_statement_line_items
          .billable
          .count
      end

      def previous_refundable_count
        @previous_refundable_count ||=
          previous_statement_line_items
          .refundable
          .count
      end

      def current_statement_line_items
        statement
        .statement_line_items
        .joins(:participant_declaration)
        .merge!(ParticipantDeclaration.for_declaration("started"))
        .merge!(ParticipantDeclaration.uplift)
      end

      def current_billable_count
        @current_billable_count ||=
          current_statement_line_items
          .billable
          .count
      end

      def current_refundable_count
        @current_refundable_count ||=
          current_statement_line_items
          .refundable
          .count
      end
    end
  end
end
