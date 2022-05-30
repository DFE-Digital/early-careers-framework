# frozen_string_literal: true

module Finance
  module NPQ
    class StatementCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def summary_overall_total
        total_overview_payment + overall_vat
      end

      def total_output_payment_subtotal
        output_payments.sum { |output_payment| output_payment[:subtotal] }
      end

      def total_service_fees
        service_fees.sum { |service_fee| service_fee[:monthly] }
      end

      def overall_vat
        total_payment * (npq_lead_provider.vat_chargeable ? 0.2 : 0.0)
      end

      def total_payment
        total_service_fees + total_output_payment_subtotal
      end

      def total_starts
        statement_declarations.started.count
      end

      def total_retained
        statement_declarations.retained.count
      end

      def total_completed
        statement_declarations.completed.count
      end

      def total_voided
        voided_declarations.count
      end

    private

      def voided_declarations
        statement.voided_participant_declarations.unique_id
      end

      def statement_declarations_per_contract(contract)
        statement
          .participant_declarations
          .for_course_identifier(contract.course_identifier)
          .unique_id
          .count
      end

      def statement_declarations
        statement.participant_declarations
      end

      def output_payments
        contracts.map do |contract|
          PaymentCalculator::NPQ::OutputPayment.call(
            contract: contract,
            total_participants: statement_declarations_per_contract(contract),
          )
        end
      end

      def total_overview_payment
        total_service_fees + total_output_payment_subtotal
      end

      def service_fees
        contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract: contract) }.compact
      end

      def contracts
        npq_lead_provider
          .npq_contracts
          .where(version: statement.contract_version)
          .order(course_identifier: :asc)
      end

      def cpd_lead_provider
        statement.cpd_lead_provider
      end

      def npq_lead_provider
        cpd_lead_provider.npq_lead_provider
      end
    end
  end
end
