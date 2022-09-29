# frozen_string_literal: true

require "payment_calculator/npq/service_fees"

module Finance
  module NPQ
    class CourseStatementCalculator
      attr_reader :statement, :contract

      def initialize(statement:, contract:)
        @statement = statement
        @contract = contract
      end

      delegate :recruitment_target, to: :contract
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
        NPQCourse.schedule_for(npq_course: course).milestones
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
        service_fees[:per_participant]
      end

      def monthly_service_fees
        contract.monthly_service_fee || calculated_service_fee
      end

      def course_total
        monthly_service_fees + output_payment_subtotal - clawback_payment
      end

    private

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
