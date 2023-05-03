# frozen_string_literal: true

module Schools
  module Cohort
    module WizardSteps
      class HowWillYouRunTrainingStep < ::WizardStep
        CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
          core_induction_programme
          school_funded_fip
          design_our_own
        ].freeze

        NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES = %i[
          full_induction_programme
          core_induction_programme
          design_our_own
        ].freeze

        PROGRAMME_CHOICES = {
          full_induction_programme: "Use a training provider, funded by the DfE",
          core_induction_programme: "Deliver your own programme using DfE-accredited materials",
          school_funded_fip: "Use a training provider funded by your school",
          design_our_own: "Design and deliver you own programme based on the early career framework (ECF)",
        }.freeze

        attr_accessor :how_will_you_run_training

        validates :how_will_you_run_training, inclusion: { in: ->(form) { form.choices.map(&:id).map(&:to_s) } }

        def self.permitted_params
          %i[how_will_you_run_training]
        end

        def choices
          (wizard.school.cip_only? ? CIP_ONLY_SCHOOL_PROGRAMME_CHOICES : NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES).map do |id|
            OpenStruct.new(id:, name: PROGRAMME_CHOICES[id])
          end
        end

        def expected?
          wizard.expect_any_ects? && !wizard.previously_fip?
        end

        def next_step
          :programme_confirmation
        end
      end
    end
  end
end
