# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class WhatChangesConfirmationStep < ::WizardStep
        def expected?
          wizard.what_changes.present?
        end

        def next_step
          :appropriate_body_appointed
        end
      end
    end
  end
end
