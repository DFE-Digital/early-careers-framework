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
        band_mapping.each do |letter, _number|
          define_method "#{event_type}_band_#{letter}_count" do
            output_calculator.banding_breakdown.find { |e| e[:band] == letter }[:"#{event_type}_count"]
          end

          define_method "#{event_type}_band_#{letter}_additions" do
            output_calculator.banding_breakdown.find { |e| e[:band] == letter }[:"#{event_type}_additions"]
          end

          define_method "#{event_type}_band_#{letter}_fee_per_declaration" do
            output_calculator.fee_for_declaration(band_letter: letter, type: event_type)
          end
        end

        define_method "additions_for_#{event_type}" do
          output_calculator.banding_breakdown.sum do |hash|
            hash[:"#{event_type}_additions"] * output_calculator.fee_for_declaration(band_letter: hash[:band], type: event_type)
          end
        end

        define_method "deductions_for_#{event_type}" do
          output_calculator.banding_breakdown.sum do |hash|
            hash[:"#{event_type}_subtractions"] * output_calculator.fee_for_declaration(band_letter: hash[:band], type: event_type)
          end
        end
      end

      def fee_for_declaration(band_letter:, type:)
        output_calculator.fee_for_declaration(band_letter:, type:)
      end

      def started_count
        output_calculator.banding_breakdown.sum do |hash|
          hash[:started_additions]
        end
      end

      def retained_count
        output_calculator.banding_breakdown.sum do |hash|
          hash.select { |k, _| k.match(/retained_\d_additions/) }.values.sum
        end
      end

      def completed_count
        output_calculator.banding_breakdown.sum do |hash|
          hash[:completed_additions]
        end
      end

      def voided_count
        voided_declarations.count
      end

      def uplift_count
        output_calculator.uplift_breakdown[:count]
      end

      def uplift_additions_count
        output_calculator.uplift_breakdown[:additions]
      end

      def uplift_deductions_count
        output_calculator.uplift_breakdown[:subtractions]
      end

      def uplift_fee_per_declaration
        statement.contract.uplift_amount
      end

      def total_for_uplift
        previous_uplift_count = output_calculator.uplift_breakdown[:previous_count]
        previous_uplift_amount = previous_uplift_count * uplift_fee_per_declaration

        delta_uplift_count = output_calculator.uplift_breakdown[:count]
        delta_uplift_amount = delta_uplift_count * uplift_fee_per_declaration

        available = [(statement.contract.uplift_cap - previous_uplift_amount), 0].max

        [available, delta_uplift_amount].min
      end

      def uplift_clawback_deductions
        uplift_deductions_count * -uplift_fee_per_declaration
      end

      def adjustments_total
        -clawback_deductions + uplift_clawback_deductions
      end

      def clawback_deductions
        event_types.sum do |event_type|
          public_send(:"deductions_for_#{event_type}")
        end
      end

      def total(with_vat: false)
        sum = service_fee + output_fee + total_for_uplift + adjustments_total + statement.reconcile_amount
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
