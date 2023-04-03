# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddRegistrationNotYetOpenStep < ::WizardStep
        def next_step
          :none
        end

        def previous_step
          :start_date
        end
      end
    end
  end
end
