# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class CompleteStep < ::WizardStep
        def next_step
          :none
        end
      end
    end
  end
end
