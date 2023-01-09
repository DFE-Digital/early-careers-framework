# frozen_string_literal: true

require "payment_calculator/npq/service_fees"

module Finance
  module NPQ
    class CourseStatementCalculator
      attr_reader :statement, :contract

      delegate :show_targeted_delivery_funding?, to: :statement

      def initialize(statement:, contract:)
        @statement = statement
        @contract = contract
      end

      delegate :recruitment_target, :targeted_delivery_funding_per_participant,
               to: :contract
      delegate :npq_lead_provider, to: :cpd_lead_provider

      def billable_declarations_count
        statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
          .count
      end

      def refundable_declarations_count
        statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
          .count
      end

      def refundable_declarations_by_type_count
        statement
          .refundable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
          .group(:declaration_type)
          .count
      end

      def billable_declarations_count_for_declaration_type(declaration_type)
        scope = statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))

        scope = if declaration_type == "retained"
                  scope.where("participant_declarations.declaration_type LIKE ?", "retained-%")
                else
                  scope.where(participant_declarations: { declaration_type: })
                end

        scope.count
      end

      def clawback_payment
        @clawback_payment ||= PaymentCalculator::NPQ::OutputPayment.call(
          contract:,
          total_participants: refundable_declarations_count,
        )[:subtotal]
      end

      def output_payment_subtotal
        output_payment[:subtotal]
      end

      def not_eligible_declarations_count
        statement
          .statement_line_items
          .where(statement_line_items: { state: %w[ineligible voided] })
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
          .count
      end

      def milestones
        NPQCourse.schedule_for(npq_course: course, cohort: contract.cohort).milestones
      end

      def declaration_count_for_milestone(milestone)
        declaration_count_by_type.fetch(milestone.declaration_type, 0)
      end

      def output_payment
        @output_payment ||= PaymentCalculator::NPQ::OutputPayment.call(
          contract:,
          total_participants: billable_declarations_count,
        )
      end

      def output_payment_per_participant
        output_payment[:per_participant]
      end

      def service_fees_per_participant
        calculated_service_fee_per_participant_derived_from_monthly_service_fee || calculated_service_fee_per_participant
      end

      def monthly_service_fees
        contract.monthly_service_fee || calculated_service_fee
      end

      def course_total
        monthly_service_fees + output_payment_subtotal - clawback_payment + targeted_delivery_funding_subtotal - targeted_delivery_funding_refundable_subtotal
      end

      def course_has_targeted_delivery_funding?
        show_targeted_delivery_funding? &&
          !(::Finance::Schedule::NPQEhco::IDENTIFIERS + ::Finance::Schedule::NPQSupport::IDENTIFIERS).compact.include?(course.identifier)
      end

      def targeted_delivery_funding_declarations_count
        return 0 unless course_has_targeted_delivery_funding?

        @targeted_delivery_funding_declarations_count ||=
          statement
              .billable_statement_line_items
              .joins(:participant_declaration)
              .joins("INNER JOIN npq_applications  ON npq_applications.id = participant_declarations.participant_profile_id")
              .where(
                participant_declarations: { course_identifier: course.identifier, declaration_type: "started" },
                npq_applications: { targeted_delivery_funding_eligibility: true, eligible_for_funding: true },
              )
              .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
              .count
      end

      def targeted_delivery_funding_subtotal
        targeted_delivery_funding_per_participant * targeted_delivery_funding_declarations_count
      end

      def targeted_delivery_funding_refundable_declarations_count
        return 0 unless course_has_targeted_delivery_funding?

        @targeted_delivery_funding_refundable_declarations_count ||=
          statement
              .refundable_statement_line_items
              .joins(:participant_declaration)
              .joins("INNER JOIN npq_applications  ON npq_applications.id = participant_declarations.participant_profile_id")
              .where(
                participant_declarations: { course_identifier: course.identifier, declaration_type: "started" },
                npq_applications: { targeted_delivery_funding_eligibility: true, eligible_for_funding: true },
              )
              .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
              .count
      end

      def targeted_delivery_funding_refundable_subtotal
        targeted_delivery_funding_per_participant * targeted_delivery_funding_refundable_declarations_count
      end

    private

      def calculated_service_fee_per_participant_derived_from_monthly_service_fee
        return unless contract.monthly_service_fee

        contract.monthly_service_fee / contract.recruitment_target
      end

      def calculated_service_fee_per_participant
        service_fees[:per_participant]
      end

      def calculated_service_fee
        service_fees[:monthly]
      end

      def service_fees
        @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract:)
      end

      def course
        @course ||= contract.npq_course
      end

      def declaration_count_by_type
        @declaration_count_by_type ||= statement
          .billable_statement_line_items
          .joins(:participant_declaration)
          .where(participant_declarations: { course_identifier: course.identifier })
          .merge(ParticipantDeclaration.select("DISTINCT (user_id, declaration_type)"))
          .group(:declaration_type)
          .count
      end

      def cpd_lead_provider
        statement.cpd_lead_provider
      end
    end
  end
end
