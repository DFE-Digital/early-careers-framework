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

        def voided_declarations
          statement.participant_declarations.voided.merge!(ParticipantDeclaration.mentor)
        end

        declaration_types.each do |declaration_type|
          define_method "#{declaration_type}_fee_per_declaration" do
            fee_for_declaration(type: declaration_type)
          end

          define_method "additions_for_#{declaration_type}" do
            output_calculator.output_breakdown.sum do |hash|
              hash[:"#{declaration_type}_additions"].to_i * output_calculator.fee_for_declaration(type: declaration_type)
            end
          end

          define_method "deductions_for_#{declaration_type}" do
            output_calculator.output_breakdown.sum do |hash|
              hash[:"#{declaration_type}_subtractions"].to_i * output_calculator.fee_for_declaration(type: declaration_type)
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

        def declaration_types_for_display
          self.class.declaration_types_for_display
        end

        def clawbacks_breakdown
          result = []

          output_calculator.banding_breakdown do |hash|
            relevant_hash = hash.select { |k, _| k.match?(/_subtractions/) }
            relevant_hash = relevant_hash.transform_keys { |k| k.to_s.gsub("_subtractions", "").to_sym }

            relevant_hash.map do |declaration_type, count|
              next if count.zero?

              fee = calculator.fee_for_declaration(type: declaration_type)

              result << {
                declaration_type: declaration_type.to_s.humanize,
                count:,
                fee: (-fee),
                subtotal: (-count * fee),
              }
            end
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

        def vat_rate
          statement.cpd_lead_provider.lead_provider.vat_chargeable? ? 0.2 : 0
        end
      end
    end
  end
end
