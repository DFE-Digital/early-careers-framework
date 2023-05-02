# frozen_string_literal: true

module Schools
  module AddParticipants
    module WizardSteps
      class EmailAlreadyTakenStep < ::WizardStep
        def next_step
          :email
        end
      end
    end
  end
end
