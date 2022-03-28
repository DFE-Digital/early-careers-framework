# frozen_string_literal: true

module Finance
  module NPQPaymentsHelper
    def number_to_pounds(number)
      number_to_currency number, precision: 2, unit: "£"
    end

    def monthly_service_fees
      service_fees[:monthly]
    end

    def service_fees_per_participant
      service_fees[:per_participant]
    end

    def output_payment_subtotal
      output_payment[:subtotal]
    end

    def output_payment_per_participant
      output_payment[:per_participant]
    end

    def total_declarations(npq_lead_provider, contract)
      if statement.current?
        ParticipantDeclaration::NPQ
          .eligible_for_lead_provider(npq_lead_provider)
          .for_course_identifier(contract.course_identifier)
          .where(statement_id: nil)
          .count
      else
        statement
          .participant_declarations
          .for_course_identifier(contract.course_identifier)
          .paid_payable_or_eligible
          .unique_id
          .count
      end
    end

    def statement_declarations
      if statement.current?
        ParticipantDeclaration::NPQ
          .for_lead_provider(npq_lead_provider)
          .eligible
          .where(statement_id: nil)
      else
        statement
          .participant_declarations
          .paid_payable_or_eligible
      end
    end

    def statement_declarations_per_contract(contract)
      if statement.current?
        ParticipantDeclaration::NPQ
          .eligible_for_lead_provider(npq_lead_provider)
          .for_course_identifier(contract.course_identifier)
          .where(statement_id: nil)
          .count
      else
        statement
          .participant_declarations
          .for_course_identifier(contract.course_identifier)
          .paid_payable_or_eligible
          .unique_id
          .count
      end
    end

    def voided_declarations
      if statement.current?
        ParticipantDeclaration::NPQ
          .for_lead_provider(npq_lead_provider)
          .where(statement_id: nil)
          .where(state: "voided")
          .unique_id
      else
        statement
          .participant_declarations
          .where(state: "voided")
          .unique_id
      end
    end

    def service_fees
      contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract: contract) }.compact
    end

    def total_service_fees_monthly
      service_fees.sum { |service_fee| service_fee[:monthly] }
    end

    def total_output_payment_subtotal
      output_payment.sum { |output_payment| output_payment[:subtotal] }
    end

    def output_payment
      contracts.map { |contract| PaymentCalculator::NPQ::OutputPayment.call(contract: contract, total_participants: statement_declarations_per_contract(contract)) }
    end

    def overall_vat
      total_payment * (npq_lead_provider.vat_chargeable ? 0.2 : 0.0)
    end

    def total_payment
      total_service_fees + total_output_payment_subtotal
    end

    def total_output_payment
      output_payment.sum { |output_payment| output_payment[:subtotal] }
    end

    def total_service_fees
      service_fees.sum { |service_fee| service_fee[:monthly] }
    end

    def total_overview_payment
      total_service_fees_monthly + total_output_payment_subtotal
    end

    def summary_overall_total
      total_overview_payment + overall_vat
    end

    delegate :deadline_date, to: :statement

    def recruitment_target_total
      contracts.sum { |contract| contract[:recruitment_target] }
    end

    def total_starts
      statement_declarations.where(declaration_type: "started").count
    end

    def total_retained
      statement_declarations.where(declaration_type: %w[retained-1 retained-2]).count
    end

    def total_completed
      statement_declarations.where(declaration_type: "completed").count
    end

    def total_voided
      voided_declarations.count
    end

    def course_total
      course_payment
    end

    def course_payment
      monthly_service_fees + output_payment_subtotal
    end
  end
end
