# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddAlreadyEnrolledAtSchoolStep < CannotAddStep
        def previous_step
          :date_of_birth
        end
      end
    end
  end
end
