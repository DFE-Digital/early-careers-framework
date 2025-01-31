# frozen_string_literal: true

module Finance
  module ECF
    class StatementCalculator
      attr_reader :statement

      delegate :contract, to: :statement

      def initialize(statement:)
        @statement = statement
      end

      def vat
        total * vat_rate
      end

      def voided_declarations
        statement.participant_declarations.voided.where(type: output_calculator.participant_declaration_class_types)
      end

      def voided_count
        voided_declarations.count
      end

      def additional_adjustments_total
        statement.adjustments.sum(:amount)
      end

      def clawback_deductions
        event_types.sum do |event_type|
          public_send(:"deductions_for_#{event_type}")
        end
      end

      def output_fee
        event_types.sum do |event_type|
          public_send(:"additions_for_#{event_type}")
        end
      end

    private

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
