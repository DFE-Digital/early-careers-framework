# frozen_string_literal: true

module Finance
  module Statements
    class Clawbacks < BaseComponent
      include FinanceHelper

      attr_reader :calculator

      def initialize(calculator:)
        @calculator = calculator
      end

      def clawbacks
        result = []

        breakdown.each do |hash|
          relevant_hash = hash.select { |k, _| k.match?(/_subtractions/) }
          relevant_hash = relevant_hash.transform_keys { |k| k.to_s.gsub("_subtractions", "").to_sym }

          relevant_hash.map do |name, count|
            next if count.zero?

            if mentor?
              fee = calculator.fee_for_declaration(type: name)
              payment_type = "Clawback for #{name.to_s.humanize}"
            else
              fee = calculator.fee_for_declaration(band_letter: hash[:band], type: name)
              payment_type = "Clawback for #{name.to_s.humanize} (Band: #{hash[:band].to_s.upcase})"
            end

            result << {
              payment_type:,
              count:,
              fee: (-fee),
              subtotal: (-count * fee),
            }
          end
        end

        result
      end

      def title
        if mentor?
          "Mentor clawbacks"
        else
          "ECT clawbacks"
        end
      end

    private

      def mentor?
        calculator.is_a?(Finance::ECF::Mentor::StatementCalculator)
      end

      def breakdown
        if mentor?
          calculator.send(:output_calculator).output_breakdown
        else
          calculator.send(:output_calculator).banding_breakdown
        end
      end
    end
  end
end
