# frozen_string_literal: true

module Finance
  module ECF
    module Mentor
      class StatementCalculator
        class << self
          def declaration_types
            %i[
              started
              completed
            ]
          end

          def declaration_types_for_display
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

        declaration_types.each do |declaration_type|
          define_method "#{declaration_type}_fee_per_declaration" do
            fee_for_declaration(type: declaration_type)
          end

          define_method "additions_for_#{declaration_type}" do
            additions = output_calculator.additions(declaration_type)
            fee = output_calculator.fee_for_declaration(type: declaration_type)
            additions * fee
          end

          define_method "deductions_for_#{declaration_type}" do
            subtractions = output_calculator.subtractions(declaration_type)
            fee = output_calculator.fee_for_declaration(type: declaration_type)
            subtractions * fee
          end
        end

        def fee_for_declaration(type:)
          output_calculator.fee_for_declaration(type:)
        end

        def started_count
          output_calculator.additions("started")
        end

        def completed_count
          output_calculator.additions("completed")
        end

        def clawed_back_count
          participant_declarations.clawed_back.count
        end

        def voided_count
          participant_declarations.voided.count
        end

        def adjustments_total
          -clawback_deductions
        end

        def clawback_deductions
          declaration_types.sum do |declaration_type|
            public_send(:"deductions_for_#{declaration_type}")
          end
        end

        def total(with_vat: false)
          sum = output_fee + adjustments_total
          sum += vat if with_vat
          sum
        end

        def output_fee
          declaration_types.sum do |declaration_type|
            public_send(:"additions_for_#{declaration_type}")
          end
        end

        delegate :declaration_types_for_display, to: :class

        def clawbacks_breakdown
          result = []

          declaration_types.each do |declaration_type|
            count = output_calculator.subtractions(declaration_type)

            next if count.zero?

            fee = fee_for_declaration(type: declaration_type)

            result << {
              declaration_type: declaration_type.to_s.humanize,
              count:,
              fee: (-fee),
              subtotal: (-count * fee),
            }
          end

          result
        end

        def ect?
          false
        end

        def mentor?
          true
        end

      private

        def output_calculator
          @output_calculator ||= OutputCalculator.new(statement:)
        end

        def declaration_types
          self.class.declaration_types
        end

        def participant_declarations
          statement.participant_declarations.merge!(ParticipantDeclaration.mentor)
        end

        def vat_rate
          statement.cpd_lead_provider.lead_provider.vat_chargeable? ? 0.2 : 0
        end
      end
    end
  end
end
