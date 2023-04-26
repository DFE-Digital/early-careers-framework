# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class ProvidersRelationshipHasChangedStep < ::WizardStep
        def next_step
          :what_changes
        end
      end
    end
  end
end
