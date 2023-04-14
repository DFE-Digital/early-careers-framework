# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CheckAnswersStep < ::WizardStep
        def before_render
          wizard.set_return_point(:check_answers)
        end

        def next_step
          :complete
        end

        def previous_step
          if wizard.sit_mentor?
            :date_of_birth
          elsif wizard.needs_to_confirm_appropriate_body?
            :confirm_appropriate_body?
          elsif wizard.mentor_options.any?
            :choose_mentor
          elsif wizard.needs_to_confirm_start_term?
            :start_term
          else
            :email
          end
        end

        def journey_complete?
          true
        end
      end
    end
  end
end
