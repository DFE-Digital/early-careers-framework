# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class SuccessStep < DfE::Wizard::Step
        def self.permitted_params
          []
        end

        def previous_step
          :check_your_answers
        end
      end
    end
  end
end
