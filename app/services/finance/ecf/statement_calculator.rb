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

      # TODO: filter according to the type of declaration in the params
      def voided_declarations
        statement.participant_declarations.voided
      end

      def voided_count
        voided_declarations.count
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
