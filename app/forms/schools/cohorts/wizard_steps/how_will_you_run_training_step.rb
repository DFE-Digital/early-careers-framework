# frozen_string_literal: true

module Schools
  module Cohorts
    module WizardSteps
      class HowWillYouRunTrainingStep < ::WizardStep
        include TrainingProgrammeOptions

        attr_accessor :how_will_you_run_training

        validates :how_will_you_run_training, inclusion: { message: "Please select an option", in: ->(form) { form.choices.map(&:id).map(&:to_s) } }

        def self.permitted_params
          %i[how_will_you_run_training]
        end

        def choices
          school_training_options(state_funded: !wizard.school.cip_only?)
        end

        def expected?
          wizard.expect_any_ects? && (!wizard.previously_fip? || wizard.cip_only_school?)
        end

        def next_step
          :programme_confirmation
        end
      end
    end
  end
end
