# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class AppropriateBodyStep < ::WizardStep
        attr_accessor :appropriate_body_id

        validates :appropriate_body_id, inclusion: { in: ->(form) { form.choices.map(&:id) } }

        def self.permitted_params
          %i[appropriate_body_id appropriate_body_type]
        end

        def choices
          @choices ||= AppropriateBody.where(body_type: "teaching_school_hub").active_in_year(wizard.cohort.start_year)
        end

        def complete?
          true
        end

        def expected?
          wizard.appropriate_body_appointed?
        end

        def next_step
          :complete
        end
      end
    end
  end
end
