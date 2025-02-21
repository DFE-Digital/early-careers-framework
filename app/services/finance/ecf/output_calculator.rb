# frozen_string_literal: true

module Finance
  module ECF
    class OutputCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def banding_for(declaration_type:)
        bandings[declaration_type]
      end

      def uplift_breakdown
        @uplift_breakdown ||= {
          previous_count: previous_fill_level_for_uplift,
          count: current_billable_count_for_uplift - current_refundable_count_for_uplift,
          additions: current_billable_count_for_uplift,
          subtractions: current_refundable_count_for_uplift,
        }
      end

      def fee_for_declaration(band_letter:, type:)
        percentage = case type
                     when :started
                       started_event_percentage
                     when :completed
                       completed_event_percentage
                     when :retained_1, :retained_2, :retained_3, :retained_4
                       retained_event_percentage
                     when :extended_1, :extended_2, :extended_3
                       extended_event_percentage
                     end

        percentage * band_for_letter(band_letter).output_payment_per_participant
      end

    private

      def bandings
        @bandings ||= declaration_types.index_with do |declaration_type|
          BandingCalculator.new(statement:, declaration_type:)
        end
      end

      def band_for_letter(letter)
        @band_for_letters ||= bands.zip(:a..:d).each_with_object({}) { |(band, lettr), hash| hash[lettr] = band }
        @band_for_letters[letter]
      end

      def started_event_percentage
        0.2
      end

      def completed_event_percentage
        0.2
      end

      def retained_event_percentage
        0.15
      end

      def extended_event_percentage
        0.15
      end

      def declaration_types
        %w[
          started
          retained-1
          retained-2
          retained-3
          retained-4
          completed
          extended-1
          extended-2
          extended-3
        ]
      end

      def bands
        statement.contract.bands.order(max: :asc)
      end

      def previous_fill_level_for_uplift
        billable = Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .billable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count

        refundable = Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .refundable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count

        billable - refundable
      end

      def current_billable_count_for_uplift
        statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration("started"))
          .merge!(ParticipantDeclaration.uplift)
          .count
      end

      def current_refundable_count_for_uplift
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
