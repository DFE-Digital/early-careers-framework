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
          elsif wizard.transfer?
            if wizard.needs_to_choose_a_mentor?
              :choose_mentor
            elsif wizard.needs_to_confirm_programme?
              :continue_current_programme
            else
              :check_answers
            end
          elsif wizard.ect_participant?
            :start_date
          else
            :check_answers
          end
        end

        def previous_step
          :date_of_birth
        end
      end
    end
  end
end
