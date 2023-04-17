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
      end
    end
  end
end
