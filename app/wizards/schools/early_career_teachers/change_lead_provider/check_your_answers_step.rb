# frozen_string_literal: true

module Schools
  module EarlyCareerTeachers
    module ChangeLeadProvider
      class CheckYourAnswersStep < DfE::Wizard::Step
        def self.permitted_params
          []
        end

        def previous_step
          :lead_provider
        end

        def next_step
          :success
        end
      end
    end
  end
end
