# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class StartTermStep < ::WizardStep
        attr_accessor :start_term

        validates :start_term, inclusion: { in: ->(form) { form.start_term_options.map(&:id) } }

        def self.permitted_params
          %i[
            start_term
          ]
        end

        def next_step
          if start_term_is_out_of_registration_scope?
            :cannot_add_registration_not_yet_open
          elsif wizard.need_training_setup?
            :need_training_setup
          elsif wizard.needs_to_choose_a_mentor?
            :choose_mentor
          elsif wizard.needs_to_confirm_appropriate_body?
            :confirm_appropriate_body
          else
            :check_answers
          end
        end

        # only visible during or just prior to the registration start for the next cohort
        def start_term_options
          year = Time.zone.today.year
          [
            OpenStruct.new(id: "summer", name: "Summer term #{year}"),
            OpenStruct.new(id: "autumn", name: "Autumn term #{year}"),
            OpenStruct.new(id: "spring", name: "Spring term #{year + 1}"),
          ]
        end

      private

        def start_term_is_out_of_registration_scope?
          # prior to registration start for the next cohort and not chosen the current cohort (summer)
          if FeatureFlag.active?(:cohortless_dashboard, for: wizard.school)
            false
          elsif Cohort.within_next_registration_period? && start_term != "summer"
            true
          else
            false
          end
        end
      end
    end
  end
end
