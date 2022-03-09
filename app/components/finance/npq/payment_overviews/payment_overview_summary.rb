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
          service_fees = []
          contracts.each do |contract|
            next if contract.service_fee_percentage.zero?

            service_fees << PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
          end
          service_fees
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

        def output_payment_cut_off_date
          statement.payment_date
        end

        def recruitment_target_total
          contracts.sum { |contract| contract[:recruitment_target] }
        end

        def total_starts
          statement_declarations.where(declaration_type: "started").unique_id.count
        end

        def total_voided
          voided_declarations
        end

        def total_retained
          statement_declarations.where(declaration_type: %w[retained-1 retained-2]).unique_id.count
        end

        def total_completed
          statement_declarations.where(declaration_type: "completed").unique_id.count
        end

        def output_payments
          output_payments = []
          contracts.each do |contract|
            output_payments << PaymentCalculator::NPQ::OutputPayment.call(contract: contract, total_participants: statement_declarations.count)
          end
          output_payments
        end

        def statement_declarations
          if statement.current?
            ParticipantDeclaration::NPQ
              .eligible_for_lead_provider(npq_lead_provider)
              .where(statement_id: nil)
          else
            statement
              .participant_declarations
              .paid_payable_or_eligible
              .unique_id
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
