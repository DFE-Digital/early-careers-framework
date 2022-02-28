# frozen_string_literal: true

module Finance
  module NPQ
    module PaymentOverviews
      class PaymentOverviewTableHeader < BaseComponent
        def initialize(contract, statement)
          self.contract = contract
          self.statement = statement
        end

        def milestones
          NPQCourse.schedule_for(course).milestones
        end

        delegate :recruitment_target, to: :contract

        def current_trainees
          statement
            .participant_declarations
            .for_course_identifier(contract.course_identifier)
            .unique_paid_payable_or_eligible
            .count
        end

        def total_not_paid
          statement
            .participant_declarations
            .for_course_identifier(contract.course_identifier)
            .ineligible.unique_id.count
        end

        def total_participants_for(milestone)
          participant_per_declaration_type.fetch(milestone.declaration_type, 0)
        end

      private

        attr_accessor :contract, :statement

        def course
          @course ||= NPQCourse.find_by!(identifier: contract.course_identifier)
        end

        def participant_per_declaration_type
          @participant_per_declaration_type ||= statement.participant_declarations
            .for_course_identifier(contract.course_identifier)
            .group(:declaration_type)
            .count
        end
      end
    end
  end
end
