# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class CompleteStep < ::WizardStep
        def expected?
          wizard.no_appropriate_body_appointed? || wizard.appropriate_body_id.present?
        end

        def next_step
          :none
        end
      end
    end
  end
end
