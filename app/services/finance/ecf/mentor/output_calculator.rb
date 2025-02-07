# frozen_string_literal: true

module Finance
  module ECF
    module Mentor
      class OutputCalculator
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
          percentage = case type
                       when :started
                         started_event_percentage
                       when :completed
                         completed_event_percentage
                       end

          percentage * statement.mentor_contract.payment_per_participant
        end

      private

        def started_event_percentage
          0.5
        end

        def completed_event_percentage
          0.5
        end

        def declaration_types
          %w[
            started
            completed
          ]
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
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.mentor)
            .count
        end

        def current_refundable_count_declaration_type(declaration_type)
          statement
            .refundable_statement_line_items
            .joins(:participant_declaration)
            .where(participant_declarations: { declaration_type: })
            .merge!(ParticipantDeclaration.mentor)
            .count
        end
      end
    end
  end
end
