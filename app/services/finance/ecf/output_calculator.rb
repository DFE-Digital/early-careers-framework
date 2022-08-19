# frozen_string_literal: true

module Finance
  module ECF
    class OutputCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def banding_breakdown
        @banding_breakdown ||= begin
          bandings = declaration_types.map do |declaration_type|
            current_banding_for_declaration_type(declaration_type)
          end

          result = bandings[0]

          band_letters.each do |letter|
            bandings[1..].each do |banding|
              new_chunk = banding.find { |e| e[:band] == letter }
              result.find { |e| e[:band] == letter }.merge!(new_chunk)
            end
          end

          result
        end
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
                     end

        percentage * band_for_letter(band_letter).output_payment_per_participant
      end

    private

      def band_for_letter(letter)
        bands.zip(:a..:z).find { |e| e[1] == letter }[0]
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

      def declaration_types
        %w[
          started
          retained-1
          retained-2
          retained-3
          retained-4
          completed
        ]
      end

      # this is a 3 pass algorithm
      # first pass adds billable declarations
      # second pass subtracts refunds
      # third pass further subtracts refunds if statement is net negative
      def current_banding_for_declaration_type(declaration_type)
        pot_size = current_billable_count_for_declaration_type(declaration_type)

        banding = previous_banding_for_declaration_type(declaration_type).map do |hash|
          byebug if declaration_type == "started"
          band_capacity = hash[:max] - (hash[:min] - 1) - hash[:"previous_#{declaration_type.underscore}_count"]

          fill_level = [pot_size, band_capacity].min

          pot_size -= fill_level

          hash[:"#{declaration_type.underscore}_count"] = fill_level
          hash[:"#{declaration_type.underscore}_additions"] = fill_level

          hash
        end

        pot_size = current_refundable_count_declaration_type(declaration_type)

        banding = banding.reverse.map do |hash|
          fill_level = hash[:"#{declaration_type.underscore}_count"]

          available = [fill_level, pot_size].min

          hash[:"#{declaration_type.underscore}_count"] = fill_level - available
          hash[:"#{declaration_type.underscore}_subtractions"] = available

          pot_size -= available

          hash
        end

        if pot_size.positive?
          banding = banding.map do |hash|
            available = hash[:"previous_#{declaration_type.underscore}_count"]

            unless available.zero?
              reduction = [pot_size, available].min

              hash[:"#{declaration_type.underscore}_count"] = -reduction
              hash[:"#{declaration_type.underscore}_subtractions"] += reduction

              pot_size -= reduction
            end

            hash
          end
        end

        banding.reverse
      end

      def previous_banding_for_declaration_type(declaration_type)
        pot_size = previous_fill_level_for_declaration_type(declaration_type)

        bands.zip(:a..:z).map do |band, letter|
          band_capacity = band.max - (band.min || 1) + 1

          fill_level = [pot_size, band_capacity].min

          pot_size -= fill_level

          key_name = "previous_#{declaration_type.underscore}_count".to_sym

          {
            band: letter,
            min: band.min || 1,
            max: band.max,
            key_name => fill_level,
          }
        end
      end

      def bands
        statement.contract.bands.order(max: :asc)
      end

      def band_letters
        bands.zip(:a..:z).map { |e| e[1] }
      end

      def previous_fill_level_for_declaration_type(declaration_type)
        billable = Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .billable
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: })
          .count

        refundable = Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .refundable
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: })
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
          .count

        refundable = Finance::StatementLineItem
          .where(statement: statement.previous_statements)
          .refundable
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: "started" })
          .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
          .count

        billable - refundable
      end

      def current_billable_count_for_declaration_type(declaration_type)
        statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: })
          .count
      end

      def current_refundable_count_declaration_type(declaration_type)
        statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: })
          .count
      end

      def current_billable_count_for_uplift
        statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: "started" })
          .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
          .count
      end

      def current_refundable_count_for_uplift
        statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { declaration_type: "started" })
          .where("participant_declarations.sparsity_uplift = true OR participant_declarations.pupil_premium_uplift = true")
          .count
      end
    end
  end
end
