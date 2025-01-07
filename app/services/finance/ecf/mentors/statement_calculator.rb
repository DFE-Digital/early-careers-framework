# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"

module Finance
  module ECF
    module Mentors
      class StatementCalculator
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
          lead_provider.vat_chargeable? ? 0.2 : 0
        end

        def cpd_lead_provider
          statement.cpd_lead_provider
        end

        def lead_provider
          cpd_lead_provider.lead_provider
        end
      end
    end
  end
end
