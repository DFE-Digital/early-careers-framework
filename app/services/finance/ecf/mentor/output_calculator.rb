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

        def output_breakdown
          @output_breakdown ||= declaration_types.map do |declaration_type|
            current_output_for_declaration_type(declaration_type)
          end
        end

        def fee_for_declaration(type:)
          percentage = DECLARATION_TYPE_FEE_PROPORTIONS[type]
          percentage * statement.mentor_contract.payment_per_participant
        end

      private

        def declaration_types
          DECLARATION_TYPE_FEE_PROPORTIONS.stringify_keys.keys
        end

        def current_output_for_declaration_type(declaration_type)
          current_output_count = current_billable_count_for_declaration_type(declaration_type)
          refundable_output_count = current_refundable_count_declaration_type(declaration_type)

          hash = {}
          hash[:"#{declaration_type.underscore}_additions"] = current_output_count
          hash[:"#{declaration_type.underscore}_subtractions"] = refundable_output_count
          hash
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
