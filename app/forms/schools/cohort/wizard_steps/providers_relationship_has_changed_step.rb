# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class ProvidersRelationshipHasChangedStep < ::WizardStep
        def expected?
          wizard.expect_any_ects? && wizard.previously_fip? && !wizard.provider_relationship_is_valid?
        end

        def next_step
          :what_changes
        end
      end
    end
  end
end
