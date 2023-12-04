# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class YourselfStep < ::WizardStep
        def next_step
          if wizard.transfer?
            if wizard.needs_to_choose_a_mentor?
              :choose_mentor
            elsif wizard.needs_to_confirm_programme?
              :continue_current_programme
            elsif wizard.needs_to_choose_school_programme?
              :join_school_programme
            else
              :cannot_add_manual_transfer
            end
          elsif wizard.needs_to_confirm_start_term?
            :start_term
          elsif wizard.needs_to_choose_a_mentor?
            :choose_mentor
          elsif wizard.needs_to_confirm_appropriate_body?
            :confirm_appropriate_body
          elsif wizard.needs_to_choose_partnership?
            :choose_partnership
          else
            :check_answers
          end
        end
      end
    end
  end
end
