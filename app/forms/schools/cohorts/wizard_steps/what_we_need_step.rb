# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class WhatWeNeedStep < ::WizardStep
        def expected?
          true
        end

        def next_step
          :expect_any_ects
        end
      end
    end
  end
end
