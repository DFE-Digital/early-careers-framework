# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddRegistrationNotYetOpenStep < CannotAddStep
        def previous_step
          :start_term
        end
      end
    end
  end
end
