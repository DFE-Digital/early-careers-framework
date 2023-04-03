# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddMentorWithoutTrnStep < CannotAddStep
        def previous_step
          :trn
        end
      end
    end
  end
end
