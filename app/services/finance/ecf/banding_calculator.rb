# frozen_string_literal: true

module Finance
  module ECF
    class BandingCalculator
      attr_reader :statement, :declaration_type

      def initialize(statement:, declaration_type:)
        @statement = statement
        @declaration_type = declaration_type
        calculate
      end

      def calculate
        add_previous_count
        add_billables
        remaining_refundables_count = adjust_for_refundables
        adjust_remaining_refundables(remaining_refundables_count)

        banding
      end

      def min(letter)
        banding_by_letter(letter)[:min]
      end

      def max(letter)
        banding_by_letter(letter)[:max]
      end

      def previous_count(letter)
        banding_by_letter(letter)[:previous_count]
      end

      def count(letter)
        banding_by_letter(letter)[:count]
      end

      def additions(letter)
        banding_by_letter(letter)[:additions]
      end

      def subtractions(letter)
        banding_by_letter(letter)[:subtractions]
      end

    private

      def bands
        @bands ||= statement.contract.bands.order(max: :asc)
      end

      def banding
        @banding ||=
          bands.zip(:a..:d).map do |band, letter|
            # minimum band should always be 1 or more, otherwise band a will go over its max limit
            band_min = band.min.to_i.zero? ? 1 : band.min
            {
              band: letter,
              min: band_min,
              max: band.max,
            }
          end
      end

      def banding_by_letter(letter)
        @banding_by_letter ||= banding.index_by do |hash|
          hash[:band]
        end

        @banding_by_letter[letter] || {}
      end

      def add_previous_count
        pot_size = previous_fill_level

        banding.each do |hash|
          band_capacity = hash[:max] - hash[:min] + 1

          fill_level = [pot_size, band_capacity].min
          hash[:previous_count] = fill_level

          pot_size -= fill_level
        end
      end

      def add_billables
        pot_size = current_billable_count

        banding.each do |hash|
          band_capacity = hash[:max] - (hash[:min] - 1) - hash[:previous_count]
          fill_level = [pot_size, band_capacity].min
          pot_size -= fill_level

          hash[:count] = fill_level
          hash[:additions] = fill_level
        end
      end

      def adjust_for_refundables
        pot_size = current_refundable_count

        banding.reverse.each do |hash|
          fill_level = hash[:count]
          available = [fill_level, pot_size].min
          pot_size -= available

          hash[:count] = fill_level - available
          hash[:subtractions] = available
        end

        pot_size
      end

      def adjust_remaining_refundables(remaining_pot_size)
        return unless remaining_pot_size.positive?

        banding.reverse.each do |hash|
          available = hash[:previous_count]
          next if available.zero?

          reduction = [remaining_pot_size, available].min
          remaining_pot_size -= reduction

          hash[:count] = -reduction
          hash[:subtractions] = (hash[:subtractions] || 0) + reduction
        end
      end

      def previous_fill_level
        previous_billable_count - previous_refundable_count
      end

      def previous_billable_count
        Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .billable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration(declaration_type))
          .count
      end

      def previous_refundable_count
        Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .refundable
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration(declaration_type))
          .count
      end

      def current_billable_count
        statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration(declaration_type))
          .count
      end

      def current_refundable_count
        statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .merge!(ParticipantDeclaration.for_declaration(declaration_type))
          .count
      end
    end
  end
end
