# frozen_string_literal: true

module Schools
  module Cohorts
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
          design_our_own: "Design and deliver your own programme based on the early career framework (ECF)",
        }.freeze

        # NOTE: These are to support 2025 programme type changes
        CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
          school_funded_fip
          core_induction_programme
        ].freeze

        NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 = %i[
          full_induction_programme
          core_induction_programme
        ].freeze

        PROGRAMME_CHOICES_2025 = {
          full_induction_programme: {
            name: "Provider-led",
            description: "Your school will work with providers who will deliver early career framework based training funded by the Department for Education.",
          },
          core_induction_programme: {
            name: "School-led",
            description: "Your school will deliver training based on the early career framework.",
          },
          school_funded_fip: {
            name: "Provider-led",
            description: "Your school will fund providers who will deliver early career framework based training.",
          },
        }.freeze

        attr_accessor :how_will_you_run_training

        validates :how_will_you_run_training, inclusion: { message: "Please select an option", in: ->(form) { form.choices.map(&:id).map(&:to_s) } }
        def self.permitted_params
          %i[how_will_you_run_training]
        end

        def choices
          if FeatureFlag.active?(:programme_type_changes_2025)
            school_choices_2025
          else
            school_choices
          end
        end

        def school_choices
          (wizard.school.cip_only? ? CIP_ONLY_SCHOOL_PROGRAMME_CHOICES : NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES).map do |id|
            OpenStruct.new(id:, name: PROGRAMME_CHOICES[id])
          end
        end

        def school_choices_2025
          (wizard.school.cip_only? ? CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025 : NON_CIP_ONLY_SCHOOL_PROGRAMME_CHOICES_2025).map do |id|
            OpenStruct.new(id:, name: PROGRAMME_CHOICES_2025[id][:name], description: PROGRAMME_CHOICES_2025[id][:description])
          end
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
