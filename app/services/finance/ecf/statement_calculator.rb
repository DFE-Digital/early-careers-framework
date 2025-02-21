# frozen_string_literal: true

require "payment_calculator/ecf/service_fees"

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

      def voided_declarations
        statement.participant_declarations.voided
      end

      event_types.each do |event_type|
        declaration_type = event_type.to_s.dasherize

        band_mapping.each_key do |letter|
          define_method "#{event_type}_band_#{letter}_count" do
            output_calculator.banding_for(declaration_type:).count(letter)
          end

          define_method "#{event_type}_band_#{letter}_additions" do
            output_calculator.banding_for(declaration_type:).additions(letter)
          end

          define_method "#{event_type}_band_#{letter}_subtractions" do
            output_calculator.banding_for(declaration_type:).subtractions(letter)
          end

          define_method "#{event_type}_band_#{letter}_fee_per_declaration" do
            output_calculator.fee_for_declaration(band_letter: letter, type: event_type)
          end
        end

        define_method "additions_for_#{event_type}" do
          band_letters.sum do |letter|
            additions = output_calculator.banding_for(declaration_type:).additions(letter)
            fee = output_calculator.fee_for_declaration(band_letter: letter, type: event_type)
            additions * fee
          end
        end

        define_method "deductions_for_#{event_type}" do
          band_letters.sum do |letter|
            subtractions = output_calculator.banding_for(declaration_type:).subtractions(letter)
            fee = output_calculator.fee_for_declaration(band_letter: letter, type: event_type)
            subtractions * fee
          end
        end
      end

      band_mapping.each_key do |letter|
        define_method "extended_band_#{letter}_additions" do
          send("extended_1_band_#{letter}_additions") +
            send("extended_2_band_#{letter}_additions") +
            send("extended_3_band_#{letter}_additions")
        end

        define_method "extended_band_#{letter}_fee_per_declaration" do
          send("extended_1_band_#{letter}_fee_per_declaration")
        end
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
        statement.participant_declarations.clawed_back.count
      end

      def voided_count
        voided_declarations.count
      end

      def uplift_count
        output_calculator.uplift_breakdown[:count]
      end

      def uplift_additions_count
        return 0.0 unless statement.contract.include_uplift_fees?

        output_calculator.uplift_breakdown[:additions]
      end

      def uplift_deductions_count
        return 0 unless statement.contract.include_uplift_fees?

        output_calculator.uplift_breakdown[:subtractions]
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

        previous_uplift_count = output_calculator.uplift_breakdown[:previous_count]
        previous_uplift_amount = previous_uplift_count * uplift_fee_per_declaration

        # uplift_clawback_deductions is a negative number so doing a double negative --
        # we're adding it back as we had subtracted from adjustments_total
        delta_uplift_amount = uplift_count * uplift_fee_per_declaration - uplift_clawback_deductions

        available = [(statement.contract.uplift_cap - previous_uplift_amount), 0].max

        [available, delta_uplift_amount].min
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

      def calculated_service_fee
        PaymentCalculator::ECF::ServiceFees.new(contract:).call.sum { |hash| hash[:monthly] }
      end

      def output_calculator
        @output_calculator ||= OutputCalculator.new(statement:)
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
