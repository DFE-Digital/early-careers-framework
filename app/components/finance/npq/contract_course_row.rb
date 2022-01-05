# frozen_string_literal: true

module Finance
  module NPQ
    class ContractCourseRow < BaseComponent
      include FinanceHelper

    private

      delegate :course_identifier, :recruitment_target, :per_participant, to: :@npq_contract

      def initialize(contract_course_row:)
        @npq_contract = contract_course_row
      end
    end
  end
end
