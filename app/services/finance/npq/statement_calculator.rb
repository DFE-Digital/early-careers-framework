# frozen_string_literal: true

require "payment_calculator/npq/service_fees"
require "payment_calculator/npq/output_payment"

module Finance
  module NPQ
    class StatementCalculator
      attr_reader :statement

      def initialize(statement:)
        @statement = statement
      end

      def summary_overall_total
        total_payment + overall_vat
      end

      def total_output_payment_subtotal
        output_payments.sum { |output_payment| output_payment[:subtotal] }
      end

      def total_service_fees
        service_fees.sum { |service_fee| service_fee[:monthly] }
      end

      def overall_vat
        total_payment * vat_rate
      end

      def total_payment
        total_service_fees + total_output_payment_subtotal + statement.reconcile_amount
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

      def vat_rate
        npq_lead_provider.vat_chargeable ? 0.2 : 0.0
      end

      def voided_declarations
        statement.participant_declarations.voided.unique_id
      end

      def statement_declarations_per_contract(contract)
        statement_declarations
          .for_course_identifier(contract.course_identifier)
          .unique_id
          .count
      end

      def statement_declarations
        statement.billable_participant_declarations
      end

      def output_payments
        contracts.map do |contract|
          PaymentCalculator::NPQ::OutputPayment.call(
            contract:,
            total_participants: statement_declarations_per_contract(contract),
          )
        end
      end

      def service_fees
        contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract:) }.compact
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
