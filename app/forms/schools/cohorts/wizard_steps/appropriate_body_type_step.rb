# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class AppropriateBodyTypeStep < ::WizardStep
        attr_accessor :appropriate_body_type

        validates :appropriate_body_type, inclusion: { in: ->(form) { form.choices.map(&:id).map(&:to_s) } }

        def self.permitted_params
          %i[appropriate_body_type]
        end

        def choices(cohort_start_year = nil)
          AppropriateBodySelectionForm.body_type_choices_for_year(cohort_start_year)
        end

        def expected?
          wizard.appropriate_body_appointed?
        end

        def next_step
          :appropriate_body
        end
      end
    end
  end
end
