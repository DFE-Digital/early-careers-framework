# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewSummary < BaseComponent
        include FinanceHelper

        def initialize(contracts, statement, npq_lead_provider)
          @contracts = contracts
          @statement = statement
          @npq_lead_provider = npq_lead_provider
        end

      private

        attr_accessor :statement, :contracts, :npq_lead_provider

        def service_fees
          contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract: contract) }.compact
        end

        def total_service_fees
          service_fees.sum { |service_fee| service_fee[:monthly] }
        end

        def total_output_payment
          output_payments.sum { |output_payment| output_payment[:subtotal] }
        end

        def total_payment
          total_service_fees + total_output_payment
        end

        def overall_vat
          total_payment * (npq_lead_provider.vat_chargeable ? 0.2 : 0.0)
        end

        def overall_total
          total_payment + overall_vat
        end

        def deadline_date
          statement.deadline_date
        end

        def recruitment_target_total
          contracts.sum { |contract| contract[:recruitment_target] }
        end

        def total_starts
          statement_declarations.where(declaration_type: "started").count
        end

        def total_voided
          voided_declarations.count
        end

        def total_retained
          statement_declarations.where(declaration_type: %w[retained-1 retained-2]).count
        end

        def total_completed
          statement_declarations.where(declaration_type: "completed").count
        end

        def output_payments
          contracts.map { |contract| PaymentCalculator::NPQ::OutputPayment.call(contract: contract, total_participants: statement_declarations_per_contract(contract)) }
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
      end
    end
  end
end
