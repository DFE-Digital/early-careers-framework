# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class KeepProvidersStep < ::WizardStep
        attr_accessor :keep_providers

        validates :keep_providers, inclusion: { in: %w[yes no] }

        def self.permitted_params
          %i[keep_providers]
        end

        def expected?
          wizard.expect_any_ects? && wizard.previously_fip? && wizard.provider_relationship_is_valid?
        end

        def keep_providers?
          keep_providers == "yes"
        end

        def next_step
          keep_providers? ? :appropriate_body_appointed : :what_changes
        end
      end
    end
  end
end
