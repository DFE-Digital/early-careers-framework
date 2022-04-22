# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTableHeader < BaseComponent
        include NPQPaymentsHelper
        delegate :recruitment_target, to: :contract

        attr_accessor :contract, :statement

        def initialize(contract, statement)
          self.contract = contract
          self.statement = statement
        end

        def milestones
          NPQCourse.schedule_for(course).milestones
        end

        def not_eligible_declarations
          statement
            .not_eligible_participant_declarations
            .for_course_identifier(contract.course_identifier)
            .unique_id
            .count
        end

        def total_participants_for(milestone)
          participants_per_declaration_type.fetch(milestone.declaration_type, 0)
        end

      private

        def course
          @course ||= NPQCourse.find_by!(identifier: contract.course_identifier)
        end

        def participants_per_declaration_type
          @participants_per_declaration_type ||= statement.participant_declarations
            .for_course_identifier(contract.course_identifier)
            .group(:declaration_type)
            .count
        end
      end
    end
  end
end
