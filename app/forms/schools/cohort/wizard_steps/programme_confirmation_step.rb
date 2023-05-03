# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class ProgrammeConfirmationStep < ::WizardStep
        def expected?
          wizard.how_will_you_run_training.present?
        end

        def next_step
          :appropriate_body_appointed
        end
      end
    end
  end
end
