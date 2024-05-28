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
          elsif wizard.adding_yourself_as_ect?
            :cannot_add_yourself_as_ect
          elsif wizard.transfer?
            if wizard.needs_to_choose_a_mentor?
              :choose_mentor
            elsif wizard.needs_to_confirm_programme?
              :continue_current_programme
            elsif wizard.needs_to_choose_school_programme?
              :join_school_programme
            else
              :cannot_add_manual_transfer
            end
          elsif wizard.sit_adding_themself_as_mentor?
            :yourself
          elsif wizard.automatically_assign_next_cohort? && !Cohort.within_next_registration_period?
            :cannot_add_registration_not_yet_open
          elsif wizard.automatically_assign_next_cohort? && wizard.need_training_setup?
            :need_training_setup
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
