# frozen_string_literal: true

module Finance
  module ECF
    module Mentor
      class StatementCalculator
        class << self
          def event_types
            %i[
              started
              completed
            ]
          end

          def event_types_for_display
            %i[
              started
              completed
            ]
          end
        end

        attr_reader :statement

        def initialize(statement:)
          @statement = statement
        end

        def vat
          total * vat_rate
        end

        def voided_declarations
          statement.participant_declarations.voided.where(type: "ParticipantDeclaration::Mentor")
        end

        event_types.each do |event_type|
          define_method "#{event_type}_fee_per_declaration" do
            fee_for_declaration(type: event_type)
          end

          define_method "additions_for_#{event_type}" do
            output_calculator.output_breakdown.sum do |hash|
              hash[:"#{event_type}_additions"].to_i * output_calculator.fee_for_declaration(type: event_type)
            end
          end

          define_method "deductions_for_#{event_type}" do
            output_calculator.output_breakdown.sum do |hash|
              hash[:"#{event_type}_subtractions"].to_i * output_calculator.fee_for_declaration(type: event_type)
            end
          end
        end

        def fee_for_declaration(type:)
          output_calculator.fee_for_declaration(type:)
        end

        def started_count
          output_calculator.output_breakdown.sum do |hash|
            hash[:started_additions].to_i
          end
        end

        def completed_count
          output_calculator.output_breakdown.sum do |hash|
            hash[:completed_additions].to_i
          end
        end

        def voided_count
          voided_declarations.count
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

        def output_fee
          event_types.sum do |event_type|
            public_send(:"additions_for_#{event_type}")
          end
        end

        def event_types_for_display
          self.class.event_types_for_display
        end

      private

        def output_calculator
          @output_calculator ||= OutputCalculator.new(statement:)
        end

        def event_types
          self.class.event_types
        end

        def vat_rate
          statement.cpd_lead_provider.lead_provider.vat_chargeable? ? 0.2 : 0
        end
      end
    end
  end
end
