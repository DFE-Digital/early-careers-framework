# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class ConfirmAppropriateBodyStep < ::WizardStep
        attr_accessor :appropriate_body_confirmed, :appropriate_body_id

        def self.permitted_params
          %i[
            appropriate_body_confirmed
          ]
        end

        def before_render
          wizard.appropriate_body_confirmed = false
        end

        def next_step
          :check_answers
        end

        def previous_step
          if wizard.ect_participant?
            if wizard.mentor_options.any?
              :choose_mentor
            else
              :start_date
            end
          else
            :email
          end
        end
      end
    end
  end
end
