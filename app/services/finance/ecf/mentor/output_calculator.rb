# frozen_string_literal: true

module Finance
  module ECF
    module Mentor
      class OutputCalculator
        DECLARATION_TYPE_FEE_PROPORTIONS = {
          started: 0.5,
          completed: 0.5,
        }.freeze

        attr_reader :statement

        def initialize(statement:)
          @statement = statement
        end

        def additions(declaration_type)
          output_breakdown["#{declaration_type}_additions"]
        end

        def subtractions(declaration_type)
          output_breakdown["#{declaration_type}_subtractions"]
        end

        def fee_for_declaration(type:)
          percentage = DECLARATION_TYPE_FEE_PROPORTIONS[type]
          percentage * statement.mentor_contract.payment_per_participant
        end

      private

        def declaration_types
          DECLARATION_TYPE_FEE_PROPORTIONS.keys
        end

        def output_breakdown
          @output_breakdown ||= declaration_types.each_with_object({}) do |declaration_type, hash|
            current_output_count = current_billable_count_for_declaration_type(declaration_type)
            refundable_output_count = current_refundable_count_declaration_type(declaration_type)

            hash["#{declaration_type}_additions"] = current_output_count
            hash["#{declaration_type}_subtractions"] = refundable_output_count
          end
        end

        def current_billable_count_for_declaration_type(declaration_type)
          statement
            .billable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.mentor)
            .count
        end

        def current_refundable_count_declaration_type(declaration_type)
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .merge!(ParticipantDeclaration.for_declaration(declaration_type))
            .merge!(ParticipantDeclaration.mentor)
            .count
        end
      end
    end
  end
end
