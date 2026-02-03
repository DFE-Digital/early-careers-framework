# frozen_string_literal: true

module Finance
  module ECF
    class UpliftCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
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
