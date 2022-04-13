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

      def vat
        total * vat_rate
      end

      def voided_declarations
        statement
          .participant_declarations
          .where(state: %w[voided])
      end

      event_types.each do |event_type|
        band_mapping.each do |letter, number|
          define_method "#{event_type}_band_#{letter}_count" do
            hash = orchestrator.call(event_type: event_type)[:output_payments].find { |h| h[:band] == number } || { participants: 0 }
            hash[:participants]
          end

          define_method "#{event_type}_band_#{letter}_fee_per_declaration" do
            hash = orchestrator.call(event_type: event_type)[:output_payments].find { |h| h[:band] == number } || { per_participant: 0 }
            hash[:per_participant]
          end
        end

        define_method "total_for_#{event_type}" do
          orchestrator.call(event_type: event_type)[:output_payments].sum { |hash| hash[:subtotal] }
        end
      end

      def started_count
        orchestrator.call(event_type: :started)[:output_payments].sum { |hash| hash[:participants] }
      end

      def retained_count
        %i[
          retained_1
          retained_2
          retained_3
          retained_4
        ].sum do |event_type|
          orchestrator.call(event_type: event_type)[:output_payments].sum { |hash| hash[:participants] }
        end
      end

      def completed_count
        orchestrator.call(event_type: :completed)[:output_payments].sum { |hash| hash[:participants] }
      end

      def voided_count
        voided_declarations.count
      end

      def uplift_count
        orchestrator.call(event_type: :started).dig(:other_fees, :uplift, :participants)
      end

      def uplift_fee_per_declaration
        orchestrator.call(event_type: :started).dig(:other_fees, :uplift, :per_participant)
      end

      def total_for_uplift
        orchestrator.call(event_type: :started).dig(:other_fees, :uplift, :subtotal)
      end

      def adjustments_total
        total_for_uplift
      end

      def total(with_vat: false)
        sum = service_fee + output_fee + adjustments_total
        sum += vat if with_vat
        sum
      end

      def service_fee
        PaymentCalculator::ECF::ServiceFees.new(contract: contract).call.sum { |hash| hash[:monthly] }
      end

      def output_fee
        event_types.map { |event_type|
          orchestrator.call(event_type: event_type)[:output_payments].sum { |hash| hash[:subtotal] }
        }.sum
      end

    private

      def open?
        statement.participant_declarations.none?
      end

      def event_types
        self.class.event_types
      end

      def band_mapping
        self.class.band_mapping
      end

      def aggregator
        @aggregator ||= aggregator_class.new(
          statement: statement,
          recorder: aggregator_scope,
        )
      end

      def aggregator_scope
        if open?
          ParticipantDeclaration::ECF
            .where(cpd_lead_provider: cpd_lead_provider)
            .unique_id
            .where(state: %w[eligible])
            .where(statement: nil)
            .where.not(state: %w[voided ineligible])
        else
          ParticipantDeclaration::ECF
            .where(state: %w[eligible payable paid])
        end
      end

      def aggregator_class
        if open?
          ParticipantEligibleAggregator
        else
          ParticipantAggregator
        end
      end

      def orchestrator
        @orchestrator ||= Finance::ECF::CalculationOrchestrator.new(
          aggregator: aggregator,
          contract: contract,
          statement: statement,
        )
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
