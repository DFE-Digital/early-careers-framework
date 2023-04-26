# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class ProgrammeConfirmationStep < ::WizardStep
        def next_step
          :appropriate_body_appointed
        end
      end
    end
  end
end
