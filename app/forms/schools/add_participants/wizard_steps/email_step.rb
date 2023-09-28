# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class EmailStep < ::WizardStep
        attr_accessor :email

        validates :email, presence: true, notify_email: true

        def self.permitted_params
          %i[
            email
          ]
        end

        def next_step
          if wizard.email_in_use?
            :email_already_taken
          elsif wizard.sit_adding_themself_as_mentor?
            :yourself
          elsif wizard.adding_yourself_as_ect?
            :cannot_add_yourself_as_ect
          elsif wizard.transfer?
            if wizard.needs_to_choose_a_mentor?
              :choose_mentor
            elsif wizard.needs_to_confirm_programme?
              :continue_current_programme
            else
              :check_answers
            end
          elsif wizard.needs_to_confirm_start_term?
            :start_term
          elsif wizard.needs_to_choose_a_mentor?
            :choose_mentor
          elsif wizard.needs_to_confirm_appropriate_body?
            :confirm_appropriate_body
          else
            :check_answers
          end
        end
      end
    end
  end
end
