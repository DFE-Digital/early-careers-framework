# frozen_string_literal: true

module Finance
  module ECF
    class StatementCalculator
      def self.event_types
        %i[
          started
          retained_1
          retained_2
          retained_3
          retained_4
          completed
          extended_1
          extended_2
          extended_3
        ]
      end

      def self.event_types_for_display
        %i[
          started
          retained_1
          retained_2
          retained_3
          retained_4
          completed
        ]
      end

      def self.band_mapping
        {
          a: 0,
          b: 1,
          c: 2,
          d: 3,
        }
      end

      attr_reader :statement

      delegate :contract, to: :statement

      def initialize(statement:)
        @statement = statement
      end

      def bands
        @bands ||= statement.contract.bands.order(max: :asc)
      end

      def band_letters
        (:a..:z).take(bands.size)
      end

      def vat
        total * vat_rate
      end

      # started band methods
      def started_band_a_additions
        output_calculator.banding_for(declaration_type: "started").additions(:a)
      end

      def started_band_a_subtractions
        output_calculator.banding_for(declaration_type: "started").subtractions(:a)
      end

      def started_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :started)
      end

      def started_band_b_additions
        output_calculator.banding_for(declaration_type: "started").additions(:b)
      end

      def started_band_b_subtractions
        output_calculator.banding_for(declaration_type: "started").subtractions(:b)
      end

      def started_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :started)
      end

      def started_band_c_additions
        output_calculator.banding_for(declaration_type: "started").additions(:c)
      end

      def started_band_c_subtractions
        output_calculator.banding_for(declaration_type: "started").subtractions(:c)
      end

      def started_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :started)
      end

      def started_band_d_additions
        output_calculator.banding_for(declaration_type: "started").additions(:d)
      end

      def started_band_d_subtractions
        output_calculator.banding_for(declaration_type: "started").subtractions(:d)
      end

      def started_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :started)
      end

      def additions_for_started
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "started").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :started)
          additions * fee
        end
      end

      def deductions_for_started
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "started").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :started)
          subtractions * fee
        end
      end

      # retained_1 band methods
      def retained_1_band_a_additions
        output_calculator.banding_for(declaration_type: "retained-1").additions(:a)
      end

      def retained_1_band_a_subtractions
        output_calculator.banding_for(declaration_type: "retained-1").subtractions(:a)
      end

      def retained_1_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :retained_1)
      end

      def retained_1_band_b_additions
        output_calculator.banding_for(declaration_type: "retained-1").additions(:b)
      end

      def retained_1_band_b_subtractions
        output_calculator.banding_for(declaration_type: "retained-1").subtractions(:b)
      end

      def retained_1_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :retained_1)
      end

      def retained_1_band_c_additions
        output_calculator.banding_for(declaration_type: "retained-1").additions(:c)
      end

      def retained_1_band_c_subtractions
        output_calculator.banding_for(declaration_type: "retained-1").subtractions(:c)
      end

      def retained_1_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :retained_1)
      end

      def retained_1_band_d_additions
        output_calculator.banding_for(declaration_type: "retained-1").additions(:d)
      end

      def retained_1_band_d_subtractions
        output_calculator.banding_for(declaration_type: "retained-1").subtractions(:d)
      end

      def retained_1_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :retained_1)
      end

      def additions_for_retained_1
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "retained-1").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_1)
          additions * fee
        end
      end

      def deductions_for_retained_1
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "retained-1").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_1)
          subtractions * fee
        end
      end

      # retained_2 band methods
      def retained_2_band_a_additions
        output_calculator.banding_for(declaration_type: "retained-2").additions(:a)
      end

      def retained_2_band_a_subtractions
        output_calculator.banding_for(declaration_type: "retained-2").subtractions(:a)
      end

      def retained_2_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :retained_2)
      end

      def retained_2_band_b_additions
        output_calculator.banding_for(declaration_type: "retained-2").additions(:b)
      end

      def retained_2_band_b_subtractions
        output_calculator.banding_for(declaration_type: "retained-2").subtractions(:b)
      end

      def retained_2_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :retained_2)
      end

      def retained_2_band_c_additions
        output_calculator.banding_for(declaration_type: "retained-2").additions(:c)
      end

      def retained_2_band_c_subtractions
        output_calculator.banding_for(declaration_type: "retained-2").subtractions(:c)
      end

      def retained_2_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :retained_2)
      end

      def retained_2_band_d_additions
        output_calculator.banding_for(declaration_type: "retained-2").additions(:d)
      end

      def retained_2_band_d_subtractions
        output_calculator.banding_for(declaration_type: "retained-2").subtractions(:d)
      end

      def retained_2_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :retained_2)
      end

      def additions_for_retained_2
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "retained-2").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_2)
          additions * fee
        end
      end

      def deductions_for_retained_2
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "retained-2").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_2)
          subtractions * fee
        end
      end

      # retained_3 band methods
      def retained_3_band_a_additions
        output_calculator.banding_for(declaration_type: "retained-3").additions(:a)
      end

      def retained_3_band_a_subtractions
        output_calculator.banding_for(declaration_type: "retained-3").subtractions(:a)
      end

      def retained_3_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :retained_3)
      end

      def retained_3_band_b_additions
        output_calculator.banding_for(declaration_type: "retained-3").additions(:b)
      end

      def retained_3_band_b_subtractions
        output_calculator.banding_for(declaration_type: "retained-3").subtractions(:b)
      end

      def retained_3_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :retained_3)
      end

      def retained_3_band_c_additions
        output_calculator.banding_for(declaration_type: "retained-3").additions(:c)
      end

      def retained_3_band_c_subtractions
        output_calculator.banding_for(declaration_type: "retained-3").subtractions(:c)
      end

      def retained_3_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :retained_3)
      end

      def retained_3_band_d_additions
        output_calculator.banding_for(declaration_type: "retained-3").additions(:d)
      end

      def retained_3_band_d_subtractions
        output_calculator.banding_for(declaration_type: "retained-3").subtractions(:d)
      end

      def retained_3_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :retained_3)
      end

      def additions_for_retained_3
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "retained-3").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_3)
          additions * fee
        end
      end

      def deductions_for_retained_3
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "retained-3").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_3)
          subtractions * fee
        end
      end

      # retained_4 band methods
      def retained_4_band_a_additions
        output_calculator.banding_for(declaration_type: "retained-4").additions(:a)
      end

      def retained_4_band_a_subtractions
        output_calculator.banding_for(declaration_type: "retained-4").subtractions(:a)
      end

      def retained_4_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :retained_4)
      end

      def retained_4_band_b_additions
        output_calculator.banding_for(declaration_type: "retained-4").additions(:b)
      end

      def retained_4_band_b_subtractions
        output_calculator.banding_for(declaration_type: "retained-4").subtractions(:b)
      end

      def retained_4_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :retained_4)
      end

      def retained_4_band_c_additions
        output_calculator.banding_for(declaration_type: "retained-4").additions(:c)
      end

      def retained_4_band_c_subtractions
        output_calculator.banding_for(declaration_type: "retained-4").subtractions(:c)
      end

      def retained_4_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :retained_4)
      end

      def retained_4_band_d_additions
        output_calculator.banding_for(declaration_type: "retained-4").additions(:d)
      end

      def retained_4_band_d_subtractions
        output_calculator.banding_for(declaration_type: "retained-4").subtractions(:d)
      end

      def retained_4_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :retained_4)
      end

      def additions_for_retained_4
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "retained-4").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_4)
          additions * fee
        end
      end

      def deductions_for_retained_4
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "retained-4").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :retained_4)
          subtractions * fee
        end
      end

      # completed band methods
      def completed_band_a_additions
        output_calculator.banding_for(declaration_type: "completed").additions(:a)
      end

      def completed_band_a_subtractions
        output_calculator.banding_for(declaration_type: "completed").subtractions(:a)
      end

      def completed_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :completed)
      end

      def completed_band_b_additions
        output_calculator.banding_for(declaration_type: "completed").additions(:b)
      end

      def completed_band_b_subtractions
        output_calculator.banding_for(declaration_type: "completed").subtractions(:b)
      end

      def completed_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :completed)
      end

      def completed_band_c_additions
        output_calculator.banding_for(declaration_type: "completed").additions(:c)
      end

      def completed_band_c_subtractions
        output_calculator.banding_for(declaration_type: "completed").subtractions(:c)
      end

      def completed_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :completed)
      end

      def completed_band_d_additions
        output_calculator.banding_for(declaration_type: "completed").additions(:d)
      end

      def completed_band_d_subtractions
        output_calculator.banding_for(declaration_type: "completed").subtractions(:d)
      end

      def completed_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :completed)
      end

      def additions_for_completed
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "completed").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :completed)
          additions * fee
        end
      end

      def deductions_for_completed
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "completed").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :completed)
          subtractions * fee
        end
      end

      # extended_1 band methods
      def extended_1_band_a_additions
        output_calculator.banding_for(declaration_type: "extended-1").additions(:a)
      end

      def extended_1_band_a_subtractions
        output_calculator.banding_for(declaration_type: "extended-1").subtractions(:a)
      end

      def extended_1_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :extended_1)
      end

      def extended_1_band_b_additions
        output_calculator.banding_for(declaration_type: "extended-1").additions(:b)
      end

      def extended_1_band_b_subtractions
        output_calculator.banding_for(declaration_type: "extended-1").subtractions(:b)
      end

      def extended_1_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :extended_1)
      end

      def extended_1_band_c_additions
        output_calculator.banding_for(declaration_type: "extended-1").additions(:c)
      end

      def extended_1_band_c_subtractions
        output_calculator.banding_for(declaration_type: "extended-1").subtractions(:c)
      end

      def extended_1_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :extended_1)
      end

      def extended_1_band_d_additions
        output_calculator.banding_for(declaration_type: "extended-1").additions(:d)
      end

      def extended_1_band_d_subtractions
        output_calculator.banding_for(declaration_type: "extended-1").subtractions(:d)
      end

      def extended_1_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :extended_1)
      end

      def additions_for_extended_1
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "extended-1").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_1)
          additions * fee
        end
      end

      def deductions_for_extended_1
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "extended-1").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_1)
          subtractions * fee
        end
      end

      # extended_2 band methods
      def extended_2_band_a_additions
        output_calculator.banding_for(declaration_type: "extended-2").additions(:a)
      end

      def extended_2_band_a_subtractions
        output_calculator.banding_for(declaration_type: "extended-2").subtractions(:a)
      end

      def extended_2_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :extended_2)
      end

      def extended_2_band_b_additions
        output_calculator.banding_for(declaration_type: "extended-2").additions(:b)
      end

      def extended_2_band_b_subtractions
        output_calculator.banding_for(declaration_type: "extended-2").subtractions(:b)
      end

      def extended_2_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :extended_2)
      end

      def extended_2_band_c_additions
        output_calculator.banding_for(declaration_type: "extended-2").additions(:c)
      end

      def extended_2_band_c_subtractions
        output_calculator.banding_for(declaration_type: "extended-2").subtractions(:c)
      end

      def extended_2_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :extended_2)
      end

      def extended_2_band_d_additions
        output_calculator.banding_for(declaration_type: "extended-2").additions(:d)
      end

      def extended_2_band_d_subtractions
        output_calculator.banding_for(declaration_type: "extended-2").subtractions(:d)
      end

      def extended_2_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :extended_2)
      end

      def additions_for_extended_2
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "extended-2").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_2)
          additions * fee
        end
      end

      def deductions_for_extended_2
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "extended-2").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_2)
          subtractions * fee
        end
      end

      # extended_3 band methods
      def extended_3_band_a_additions
        output_calculator.banding_for(declaration_type: "extended-3").additions(:a)
      end

      def extended_3_band_a_subtractions
        output_calculator.banding_for(declaration_type: "extended-3").subtractions(:a)
      end

      def extended_3_band_a_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :a, type: :extended_3)
      end

      def extended_3_band_b_additions
        output_calculator.banding_for(declaration_type: "extended-3").additions(:b)
      end

      def extended_3_band_b_subtractions
        output_calculator.banding_for(declaration_type: "extended-3").subtractions(:b)
      end

      def extended_3_band_b_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :b, type: :extended_3)
      end

      def extended_3_band_c_additions
        output_calculator.banding_for(declaration_type: "extended-3").additions(:c)
      end

      def extended_3_band_c_subtractions
        output_calculator.banding_for(declaration_type: "extended-3").subtractions(:c)
      end

      def extended_3_band_c_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :c, type: :extended_3)
      end

      def extended_3_band_d_additions
        output_calculator.banding_for(declaration_type: "extended-3").additions(:d)
      end

      def extended_3_band_d_subtractions
        output_calculator.banding_for(declaration_type: "extended-3").subtractions(:d)
      end

      def extended_3_band_d_fee_per_declaration
        output_calculator.fee_for_declaration(band_letter: :d, type: :extended_3)
      end

      def additions_for_extended_3
        band_letters.sum do |letter|
          additions = output_calculator.banding_for(declaration_type: "extended-3").additions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_3)
          additions * fee
        end
      end

      def deductions_for_extended_3
        band_letters.sum do |letter|
          subtractions = output_calculator.banding_for(declaration_type: "extended-3").subtractions(letter)
          fee = output_calculator.fee_for_declaration(band_letter: letter, type: :extended_3)
          subtractions * fee
        end
      end

      # extended aggregate methods (combines extended_1, extended_2, extended_3)
      def extended_band_a_additions
        extended_1_band_a_additions + extended_2_band_a_additions + extended_3_band_a_additions
      end

      def extended_band_a_fee_per_declaration
        extended_1_band_a_fee_per_declaration
      end

      def extended_band_b_additions
        extended_1_band_b_additions + extended_2_band_b_additions + extended_3_band_b_additions
      end

      def extended_band_b_fee_per_declaration
        extended_1_band_b_fee_per_declaration
      end

      def extended_band_c_additions
        extended_1_band_c_additions + extended_2_band_c_additions + extended_3_band_c_additions
      end

      def extended_band_c_fee_per_declaration
        extended_1_band_c_fee_per_declaration
      end

      def extended_band_d_additions
        extended_1_band_d_additions + extended_2_band_d_additions + extended_3_band_d_additions
      end

      def extended_band_d_fee_per_declaration
        extended_1_band_d_fee_per_declaration
      end

      def additions_for_extended
        additions_for_extended_1 + additions_for_extended_2 + additions_for_extended_3
      end

      def fee_for_declaration(band_letter:, type:)
        output_calculator.fee_for_declaration(band_letter:, type:)
      end

      def started_count
        band_letters.sum do |letter|
          output_calculator.banding_for(declaration_type: "started").additions(letter)
        end
      end

      def retained_types
        event_types.select { |t| t.starts_with?("retained_") }
      end

      def retained_count
        band_letters.sum do |letter|
          retained_types.sum do |event_type|
            output_calculator.banding_for(declaration_type: event_type.to_s.dasherize).additions(letter)
          end
        end
      end

      def completed_count
        band_letters.sum do |letter|
          output_calculator.banding_for(declaration_type: "completed").additions(letter)
        end
      end

      def extended_types
        event_types.select { |t| t.starts_with?("extended_") }
      end

      def extended_count
        band_letters.sum do |letter|
          extended_types.sum do |event_type|
            output_calculator.banding_for(declaration_type: event_type.to_s.dasherize).additions(letter)
          end
        end
      end

      def clawed_back_count
        participant_declarations.clawed_back.count
      end

      def voided_count
        participant_declarations.voided.count
      end

      def uplift_count
        output_calculator.uplift.count
      end

      def uplift_additions_count
        return 0.0 unless statement.contract.include_uplift_fees?

        output_calculator.uplift.additions
      end

      def uplift_deductions_count
        return 0 unless statement.contract.include_uplift_fees?

        output_calculator.uplift.subtractions
      end

      def uplift_fee_per_declaration
        return 0.0 unless statement.contract.include_uplift_fees?

        statement.contract.uplift_amount
      end

      def uplift_payment
        uplift_additions_count * uplift_fee_per_declaration
      end

      def total_for_uplift
        return 0.0 unless statement.contract.include_uplift_fees?

        # uplift_clawback_deductions is a negative number so doing a double negative --
        # we're adding it back as we had subtracted from adjustments_total
        uplift_count * uplift_fee_per_declaration - uplift_clawback_deductions
      end

      def uplift_clawback_deductions
        uplift_deductions_count * -uplift_fee_per_declaration
      end

      def adjustments_total
        -clawback_deductions + uplift_clawback_deductions
      end

      def additional_adjustments_total
        statement.adjustments.sum(:amount)
      end

      def clawback_deductions
        event_types.sum do |event_type|
          public_send(:"deductions_for_#{event_type}")
        end
      end

      def total(with_vat: false)
        sum = service_fee + output_fee + total_for_uplift + adjustments_total + additional_adjustments_total + statement.reconcile_amount
        sum += vat if with_vat
        sum
      end

      def service_fee
        contract.monthly_service_fee || calculated_service_fee
      end

      def output_fee
        event_types.sum do |event_type|
          public_send(:"additions_for_#{event_type}")
        end
      end

      def event_types_for_display
        self.class.event_types_for_display.tap do |types|
          types << :extended if extended_count.positive?
        end
      end

      def clawbacks_breakdown
        result = []

        band_letters.each do |band_letter|
          event_types.each do |event_type|
            count = send("#{event_type}_band_#{band_letter}_subtractions")
            next if count.zero?

            fee = fee_for_declaration(band_letter:, type: event_type)

            result << {
              declaration_type: event_type.to_s.humanize,
              band: band_letter.to_s.upcase,
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
        false
      end

    private

      delegate :participant_declarations, to: :statement

      NUMBER_OF_SERVICE_FEE_PAYMENTS = 29

      def calculated_service_fee
        bands.sum { |band| band.service_fee_total / NUMBER_OF_SERVICE_FEE_PAYMENTS }
      end

      def output_calculator
        @output_calculator ||= self.class.module_parent::OutputCalculator.new(statement:)
      end

      def event_types
        self.class.event_types
      end

      def band_mapping
        self.class.band_mapping
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
