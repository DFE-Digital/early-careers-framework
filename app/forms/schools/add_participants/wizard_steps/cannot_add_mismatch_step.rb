# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class CannotAddMismatchStep < ::WizardStep
        def next_step
          :none
        end

        def previous_step
          :known_by_another_name
        end
      end
    end
  end
end
