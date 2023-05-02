# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class WhatWeNeedStep < ::WizardStep
        def next_step
          :expect_any_ects
        end
      end
    end
  end
end
