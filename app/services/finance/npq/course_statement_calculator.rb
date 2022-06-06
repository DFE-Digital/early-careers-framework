# frozen_string_literal: true

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

      def total_declarations
        statement
          .participant_declarations
          .for_course_identifier(course.identifier)
          .unique_id
          .count
      end

      def output_payment_subtotal
        output_payment[:subtotal]
      end

      def not_eligible_declarations
        statement
          .not_eligible_participant_declarations
          .for_course_identifier(course.identifier)
          .unique_id
          .count
      end

      def milestones
        NPQCourse.schedule_for(npq_course: course).milestones
      end

      def total_participants_for(milestone)
        participants_per_declaration_type.fetch(milestone.declaration_type, 0)
      end

      def output_payment
        @output_payment ||= PaymentCalculator::NPQ::OutputPayment.call(
          contract: contract,
          total_participants: total_declarations,
        )
      end

      def output_payment_per_participant
        output_payment[:per_participant]
      end

      def service_fees_per_participant
        service_fees[:per_participant]
      end

      def monthly_service_fees
        service_fees[:monthly]
      end

      def service_fees
        @service_fees ||= PaymentCalculator::NPQ::ServiceFees.call(contract: contract)
      end

      def course_total
        monthly_service_fees + output_payment_subtotal
      end

    private

      def course
        contract.npq_course
      end

      def participants_per_declaration_type
        @participants_per_declaration_type ||= statement
          .participant_declarations
          .for_course_identifier(course.identifier)
          .group(:declaration_type)
          .count
      end

      def cpd_lead_provider
        statement.cpd_lead_provider
      end
    end
  end
end
