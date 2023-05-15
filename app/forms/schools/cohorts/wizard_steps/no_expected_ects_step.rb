# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class NoExpectedEctsStep < ::WizardStep
        def expected?
          wizard.no_expect_any_ects?
        end

        def next_step
          :none
        end
      end
    end
  end
end
