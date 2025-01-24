# frozen_string_literal: true

module Finance
  module ECF
    module Mentor
      class StatementCalculator < Finance::ECF::StatementCalculator
        def self.event_types
          %i[
            started
            completed
          ]
        end

        def self.event_types_for_display
          %i[
            started
            completed
          ]
        end

        attr_reader :statement, :contract

        def initialize(statement:)
          @statement = statement
          @contract = statement.mentor_contract
        end

        def vat
          total * vat_rate
        end

        def voided_declarations
          statement.participant_declarations.voided.where(type: "ParticipantDeclaration::Mentor")
        end

        event_types.each do |event_type|
          define_method "#{event_type}_fee_for_declaration" do
            fee_for_declaration(type: event_type)
          end

          define_method "additions_for_#{event_type}" do
            hash = {}.merge(*output_calculator.output_breakdown)
            hash[:"#{event_type}_additions"] * output_calculator.fee_for_declaration(type: event_type)
          end

          define_method "deductions_for_#{event_type}" do
            hash = {}.merge(*output_calculator.output_breakdown)
            hash[:"#{event_type}_subtractions"] * output_calculator.fee_for_declaration(type: event_type)
          end
        end

        def fee_for_declaration(type:)
          output_calculator.fee_for_declaration(type:)
        end

        def started_count
          hash = {}.merge(*output_calculator.output_breakdown)
          hash[:started_additions]
        end

        def completed_count
          hash = {}.merge(*output_calculator.output_breakdown)
          hash[:completed_additions]
        end

        def adjustments_total
          -clawback_deductions
        end

        def clawback_deductions
          event_types.sum do |event_type|
            public_send(:"deductions_for_#{event_type}")
          end
        end

        def total(with_vat: false)
          sum = output_fee + adjustments_total
          sum += vat if with_vat
          sum
        end

        def event_types_for_display
          self.class.event_types_for_display
        end

      private

        def output_calculator
          @output_calculator ||= OutputCalculator.new(statement:)
        end
      end
    end
  end
end
