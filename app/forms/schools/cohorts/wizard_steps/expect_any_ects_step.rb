# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class ExpectAnyEctsStep < ::WizardStep
        attr_accessor :expect_any_ects

        validates :expect_any_ects, inclusion: { in: %w[yes no] }

        def self.permitted_params
          %i[expect_any_ects]
        end

        def expected?
          true
        end

        def complete?
          !expect_any_ects?
        end

        def expect_any_ects?
          expect_any_ects == "yes"
        end

        def next_step
          return :no_expected_ects unless expect_any_ects?
          return :how_will_you_run_training unless wizard.previously_fip_with_active_partnership?
          return :keep_providers if wizard.provider_relationship_is_valid?

          :providers_relationship_has_changed
        end
      end
    end
  end
end
